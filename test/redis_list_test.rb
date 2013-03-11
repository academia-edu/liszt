require 'test_helper'

describe Liszt::RedisList do
  describe "the Redis list wrapper" do
    before do
      Liszt.redis.flushall
      @list = Liszt::RedisList.new('liszt:test')
    end

    it "clears and populate successfully" do
      @list.clear_and_populate!([1,2,3])
      @list.clear_and_populate!([4,5,6])
      assert_equal @list.to_a, [4,5,6]
    end

    it "isn't initialized before it's initialized" do
      assert !@list.initialized?
    end

    it "is initialized once it's initialized" do
      @list.clear_and_populate!([1])
      assert @list.initialized?
    end

    describe "given a list with some ids" do
      before do
        @list.clear_and_populate!([1,5,4,2])
      end

      it "knows if the list includes an id" do
        assert @list.include?(4)
        assert !@list.include?(3)
      end

      it "knows the index of an id" do
        assert_equal @list.index(1), 0
        assert_equal @list.index(4), 2
        assert_equal @list.index(2), 3
      end

      it "unshifts onto the front of the list" do
        @list.unshift(8)
        assert_equal @list.to_a, [8,1,5,4,2]
      end

      it "doesn't unshift if already present" do
        @list.unshift(5)
        assert_equal @list.to_a, [1,5,4,2]
      end

      it "unshift!s if already present" do
        @list.unshift!(5)
        assert_equal @list.to_a, [5,1,5,4,2]
      end

      it "pushes onto the end of the list" do
        @list.push(8)
        assert_equal @list.to_a, [1,5,4,2,8]
      end

      it "doesn't push if already present" do
        @list.push(5)
        assert_equal @list.to_a, [1,5,4,2]
      end

      it "push!es if already present" do
        @list.push!(5)
        assert_equal @list.to_a, [1,5,4,2,5]
      end

      it "removes an id" do
        @list.remove(5)
        assert_equal @list.to_a, [1,4,2]
      end

      it "clears all ids without un-initializing" do
        @list.clear
        assert @list.initialized?
        assert_equal @list.to_a, []
      end

      it "knows the length of the list" do
        assert_equal @list.length, 4
      end

      it "returns nil for length if uninitialized" do
        @list.uninitialize
        assert_nil @list.length
      end

      it "returns all ids (and no marker) for .all/.to_a" do
        assert_equal @list.all, [1,5,4,2]
      end

      it "moves an id down from the top" do
        @list.move_down(1)
        assert_equal @list.to_a, [5,1,4,2]
      end

      it "moves an id down from the middle" do
        @list.move_down(4)
        assert_equal @list.to_a, [1,5,2,4]
      end

      it "doesn't move an id down from the bottom" do
        @list.move_down(2)
        assert_equal @list.to_a, [1,5,4,2]
      end

      it "doesn't move an id up from the top" do
        @list.move_up(1)
        assert_equal @list.to_a, [1,5,4,2]
      end

      it "moves an id up from the middle" do
        @list.move_up(4)
        assert_equal @list.to_a, [1,4,5,2]
      end

      it "moves an id up from the bottom" do
        @list.move_up(2)
        assert_equal @list.to_a, [1,5,2,4]
      end

      it "moves an id to the top from the top" do
        @list.move_to_top(1)
        assert_equal @list.to_a, [1,5,4,2]
      end

      it "moves an id to the top" do
        @list.move_to_top(4)
        assert_equal @list.to_a, [4,1,5,2]
      end

      it "moves an id to the bottom" do
        @list.move_to_bottom(4)
        assert_equal @list.to_a, [1,5,2,4]
      end

      it "doesn't move an id to the bottom from the bottom" do
        @list.move_to_bottom(2)
        assert_equal @list.to_a, [1,5,4,2]
      end
    end

    describe "locking mechanism" do
      it "gets an exclusive lock" do
        assert @list.send(:get_lock)
        assert !@list.send(:get_lock)
        @list.send(:release_lock)
      end

      it "releases the lock" do
        @list.send(:get_lock)
        @list.send(:release_lock)
        assert @list.send(:get_lock)
        @list.send(:release_lock)
      end

      it "times out the lock" do
        @list.send(:get_lock, 0)
        sleep(0.1)
        assert @list.send(:get_lock)
      end
    end
  end
end
