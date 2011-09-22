require 'test_helper'

class LisztTest < ActiveSupport::TestCase
  fixtures :groups
  fixtures :people

  setup do
    Liszt.redis.flushall
  end

  context "before initialization" do
    should "not be initialized" do
      assert !people(:nelson).ordered_list_initialized?
    end

    should "initialize successfully" do
      assert_nothing_raised { people(:nelson).initialize_list! }
      assert people(:nelson).ordered_list_initialized?
    end
  end
end
