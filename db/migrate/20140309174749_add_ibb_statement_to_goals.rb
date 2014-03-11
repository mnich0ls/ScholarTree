class AddIbbStatementToGoals < ActiveRecord::Migration
  def change
    change_table :goals do |t|
      t.text :belief_statement
    end
  end
end
