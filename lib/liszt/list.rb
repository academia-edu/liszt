module Liszt
  class InvalidListError < StandardError
  end

  class List
    def initialize(key)
      @key = key
    end

    def include?(id)
      to_a.include?(id.to_s)
    end

    def unshift(obj)
      unless include?(obj.id)
        redis.lpush(@key, obj.id)
      end
    end

    def push(obj)
      unless include?(obj.id)
        redis.rpush(@key, obj.id)
      end
    end
    alias << push

    def remove(obj)
      redis.lrem(@key, 1, obj.id)
    end

    def clear
      redis.del(@key)
    end

    def index_of(obj)
      to_a.find_index(obj.id.to_s)
    end

    def length
      redis.llen(@key)
    end

    def get(index)
      redis.lindex(@key, index)
    end

    def set(index, value)
      redis.lset(@key, index, value)
    end

    def clear_and_populate!(objs)
      redis.multi do
        clear
        objs.each { |o| redis.lpush(@key, o.id) }
      end
    end

    def move_to_top(obj)
      redis.multi do
        remove(obj)
        redis.lpush(@key, obj.id)
      end
    end

    def move_up(obj)
      with_lock do
        position = index_of(obj)
        if position.nil?
          raise InvalidListError
        elsif position == 0
          move_to_top(obj)
        else
          prev_id = get(position - 1)
          redis.multi do
            set(position - 1, obj.id)
            set(position, prev_id)
          end
        end
      end
    end

    def move_down(obj)
      with_lock do
        position = index_of(obj)
        if position.nil?
          raise InvalidListError
        elsif position == (length - 1)
          move_to_bottom(obj)
        else
          next_id = get(position + 1)
          redis.multi do
            set(position + 1, obj.id)
            set(position, next_id)
          end
        end
      end
    end

    def move_to_bottom(obj)
      redis.multi do
        remove(obj)
        redis.rpush(@key, obj.id)
      end
    end

    def to_a
      redis.lrange(@key, 0, -1)
    end

    private
      def redis
        ::Liszt.redis
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
