class Goal < ActiveRecord::Base
  belongs_to :user
  has_many :goal_priorities
  has_many :goal_resources
  accepts_nested_attributes_for :goal_priorities
  accepts_nested_attributes_for :goal_resources

  def priority
    goal_prioritiy = GoalPriority.where('goal_id' => self.id).order('created_at DESC').limit(1).first
    goal_prioritiy.priority
  end
end