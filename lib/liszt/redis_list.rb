module Liszt
  class RedisList
    # @param [String] key The Redis key associated with this list.
    def initialize(key)
      @key = key
    end

    # Remove existing list items and repopulate the list with the given ids
    # (in the given order).
    # @param [Array<Fixnum>] ids
    # @return [Array<Fixnum>]
    def clear_and_populate!(ids, &block)
      redis.multi do
        clear
        # reverse and unshift to avoid touching the marker
        ids.reverse.each { |id| unshift!(id) }
      end
      ids
    end

    # Has the list been initialized?
    # @return [Boolean]
    def initialized?
      !length.nil?
    end

    # Does the list currently include this id?
    # @param [Fixnum] id
    # @return [Boolean]
    def include?(id)
      all.include?(id)
    end

    # Return the index of the given id in the list.
    # @param [Fixnum] id
    # @return [Fixnum]
    def index(id)
      all.index(id)
    end

    # Push the given id onto the top of the list, if not already present.
    # @param [Fixnum] id
    # @return [Boolean] <tt>false</tt> if the item was already in the list,
    #   <tt>true</tt> otherwise.
    def unshift(id)
      if include?(id)
        false
      else
        unshift!(id)
        true
      end
    end

    # Push the given id onto the top of the list.
    # @param [Fixnum] id
    def unshift!(id)
      redis.lpush(@key, id)
    end

    # Push the given id onto the bottom of the list, if not already present.
    # @param [Fixnum] id
    # @return [Boolean] <tt>false</tt> if the item was already in the list,
    #   <tt>true</tt> otherwise.
    def push(id)
      if include?(id)
        false
      else
        push!(id)
        true
      end
    end
    alias << push

    # Push the given id onto the bottom of the list.
    # @param [Fixnum] id
    def push!(id)
      redis.rpop(@key)
      redis.rpush(@key, id)
      redis.rpush(@key, '*')
    end

    # Remove the given id from the list.
    # @param [Fixnum] id
    def remove(id)
      redis.lrem(@key, 1, id)
    end

    # Clear all items from the list.
    def clear
      redis.del(@key)
      redis.rpush(@key, '*')
    end

    # Return the number of ids in the list, or nil if it's uninitialized.
    # @return [Fixnum]
    # @return [nil]
    def length
      len = redis.llen(@key)
      (len > 0) ? (len - 1) : nil
    end

    # Return an Array of all the ids in the list.
    # @return [Array<Fixnum>]
    def all
      redis.lrange(@key, 0, -2).map(&:to_i)
    end
    alias to_a all

    # Swap the position of the given id with the one above it. If it's at the
    # top of the list or not present in the list, do nothing.
    # @param [Fixnum] id
    def move_up(id)
      with_lock do
        position = index(id)
        if position.nil? or position == 0
          nil
        else
          prev_id = get(position - 1)
          redis.multi do
            set(position - 1, id)
            set(position, prev_id)
          end
        end
      end
    end

    # Swap the position of the given id with the one below it. If it's at the
    # bottom of the list or not present in the list, do nothing.
    # @param [Fixnum] id
    def move_down(id)
      with_lock do
        position = index(id)
        if position.nil? or position == (length - 1)
          nil
        else
          next_id = get(position + 1)
          redis.multi do
            set(position + 1, id)
            set(position, next_id)
          end
        end
      end
    end

    # Move the given id to the top of the list.
    # @param [Fixnum] id
    def move_to_top(id)
      redis.multi do
        remove(id)
        unshift!(id)
      end
    end

    # Move the given id to the bottom of the list.
    # @param [Fixnum] id
    def move_to_bottom(id)
      redis.multi do
        remove(id)
        push!(id)
      end
    end

    private
      def redis
        ::Liszt.redis
      end

      # Return the item at the given index in the list.
      # @param [Fixnum] index
      def get(index)
        redis.lindex(@key, index).to_i
      end

      def set(index, value)
        redis.lset(@key, index, value)
      end

      # Obtain an exclusive lock on the list, execute the given block, and then
      # release the lock. If the lock is currently taken by someone else, we just
      # block until it becomes available.
      def with_lock
        start_time = Time.now
        until get_lock
          sleep 0.25
          raise "Timed out!" if (Time.now - start_time) > 2.0
        end
        yield
      ensure
        release_lock
      end

      def get_lock
        if redis.setnx(lock_key, true)
          redis.expire(lock_key, lock_expiration_time)
          true
        else
          false
        end
      end

      def release_lock
        redis.del(lock_key)
      end

      def lock_key
        "#{@key}:lock"
      end

      def lock_expiration_time
        5 # seconds
      end
  end
end
