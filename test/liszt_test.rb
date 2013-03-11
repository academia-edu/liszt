require 'test_helper'

describe Liszt do
  before do
    Liszt.redis.flushall
  end

  describe "before initialization" do
    it "isn't initialized" do
      assert !people(:nelson).ordered_list_initialized?
    end

    it "initializes successfully" do
      people(:nelson).initialize_list!
      assert people(:nelson).ordered_list_initialized?
    end

    it "auto-initializes successfully" do
      people(:nelson).ordered_list_ids
      assert people(:nelson).ordered_list_initialized?
    end
  end

  describe "after initialization" do
    before do
      people(:nelson).initialize_list!(&:id)
      @id = people(:nelson).id
      @current_list = Person.ordered_list_ids(people(:nelson))
    end

    describe "basic functionality" do
      it "moves to top" do
        people(:nelson).move_to_top!
        @current_list.delete(@id)
        @current_list.unshift(@id)
        assert_equal people(:nelson).ordered_list_ids, @current_list
      end

      it "moves up" do
        old_index = people(:nelson).ordered_list_ids.index(@id)
        people(:nelson).move_up!
        @current_list.swap(old_index, old_index - 1)
        assert_equal people(:nelson).ordered_list_ids, @current_list
      end

      it "moves down" do
        old_index = people(:nelson).ordered_list_ids.index(@id)
        people(:nelson).move_down!
        @current_list.swap(old_index, old_index + 1)
        assert_equal people(:nelson).ordered_list_ids, @current_list
      end

      it "moves to bottom" do
        people(:nelson).move_to_bottom!
        @current_list.delete(@id)
        @current_list.push(@id)
        assert_equal people(:nelson).ordered_list_ids, @current_list
      end
    end

    describe "ActiveRecord hooks" do
      before do
        Person.initialize_list!(:group_id => 1, :is_male => true)
        @person = Person.new(:name => "John Smith", :group_id => 1, :is_male => true)
      end

      it "isn't in list before saving" do
        assert !@person.ordered_list_items.include?(@person)
      end

      it "is in list after saving" do
        @person.save
        assert @person.ordered_list_items.include?(@person)
      end

      it "is removed from list after deletion" do
        @person.save
        @person.destroy
        assert !@person.ordered_list_items.include?(@person)
      end
    end

    describe "options" do
      before do
        Person.initialize_list!(:group_id => 1, :is_male => true)
        @person = Person.new(:name => "John Smith", :group_id => 1, :is_male => true)
      end

      it "doesn't confirm the list when force_refresh is nil" do
        @person.save
        @person.remove_from_list
        assert !@person.ordered_list_items.include?(@person)
        assert !@person.ordered_list_ids.include?(@person.id)
      end

      it "confirms the list when force_refresh is true" do
        @person.save
        @person.remove_from_list
        assert @person.ordered_list_items(:force_refresh => true).include?(@person)
        assert @person.ordered_list_ids.include?(@person.id)
      end

      it "passes any other options through to the ActiveRecord query" do
        @person.save
        assert @person.ordered_list_items(:limit => 2).count == 2
      end
    end
  end

  describe "auto-initialization" do
    before do
      Group.acts_as_liszt :sort_by => lambda { |o| o.id }
    end

    it "sorts a newly initialized list with the given proc" do
      assert !Group.ordered_list_initialized?
      Group.initialize_list!
      assert Group.ordered_list_initialized?
      assert_equal Group.ordered_list_ids, [1, 2, 3]
    end

    it "sorts a newly auto-initialized list with the given proc" do
      g = Group.new
      assert !Group.ordered_list_initialized?
      g.save
      assert Group.ordered_list_initialized?
      assert_equal Group.ordered_list_ids, [1, 2, 3, g.id]
    end
  end
end
