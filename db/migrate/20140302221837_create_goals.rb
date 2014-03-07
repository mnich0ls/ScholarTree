class CreateGoals < ActiveRecord::Migration
  def change
    create_table :goals do |t|
      t.string      :title
      t.date        :timeline_target_completion_date
      t.string      :timeline_category # Short term, long term, lifetime, etc..
      t.date        :completed_on

      t.references  :user, column_options: {null: false}

      t.timestamps
    end

    create_table :goal_priorities do |t|
      t.float       :priority

      t.references  :goal, column_options: {null: false}

      t.timestamps
    end

    create_table :goal_resources do |t|
      t.string      :name # Time, money, confidence, etc.
      t.float       :allocation # How much of this resource does the user have?

      t.references  :goal, column_options: {null: false}

      t.timestamps
    end
  end
end
