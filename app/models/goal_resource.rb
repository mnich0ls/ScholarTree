class GoalResource < ActiveRecord::Base
  belongs_to :goal

  attr_accessor :freeform_name
end