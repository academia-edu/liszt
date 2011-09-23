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

  context "after initialization" do
    setup do
      people(:nelson).initialize_list!(&:id)
      @id = people(:nelson).id
      @current_list = Person.ordered_list_ids(people(:nelson))
    end

    context "basic functionality" do
      should "move to top" do
        people(:nelson).move_to_top!
        @current_list.delete(@id)
        @current_list.unshift(@id)
        assert_equal people(:nelson).ordered_list_ids, @current_list
      end

      should "move up" do
        old_index = people(:nelson).ordered_list_ids.index(@id)
        people(:nelson).move_up!
        @current_list.swap(old_index, old_index - 1)
        assert_equal people(:nelson).ordered_list_ids, @current_list
      end

      should "move down" do
        old_index = people(:nelson).ordered_list_ids.index(@id)
        people(:nelson).move_down!
        @current_list.swap(old_index, old_index + 1)
        assert_equal people(:nelson).ordered_list_ids, @current_list
      end

      should "move to bottom" do
        people(:nelson).move_to_bottom!
        @current_list.delete(@id)
        @current_list.push(@id)
        assert_equal people(:nelson).ordered_list_ids, @current_list
      end
    end

    context "ActiveRecord hooks" do
      setup do
        Person.initialize_list!(:group_id => 1, :is_male => true)
        @person = Person.new(:name => "John Smith", :group_id => 1, :is_male => true)
      end

      should "not be in list before saving" do
        assert !@person.ordered_list_items.include?(@person)
      end

      should "be in list after saving" do
        @person.save
        assert @person.ordered_list_items.include?(@person)
      end

      should "be removed from list after deletion" do
        @person.save
        @person.destroy
        assert !@person.ordered_list_items.include?(@person)
      end
    end

    context "double_check" do
      setup do
        Person.initialize_list!(:group_id => 1, :is_male => true)
        @person = Person.new(:name => "John Smith", :group_id => 1, :is_male => true)
      end

      should "not confirm the list when double_check=false" do
        @person.save
        @person.remove_from_list
        assert !@person.ordered_list_items.include?(@person)
        assert !@person.ordered_list_ids.include?(@person.id)
      end

      should "confirm the list when double_check=true" do
        @person.save
        @person.remove_from_list
        assert @person.ordered_list_items(true).include?(@person)
        assert @person.ordered_list_ids.include?(@person.id)
      end
    end
  end
end
