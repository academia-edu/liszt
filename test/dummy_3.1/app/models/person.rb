class Person < ActiveRecord::Base
  acts_as_liszt :scope => [:group_id, :is_male]
end
