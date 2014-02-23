class CreateJournals < ActiveRecord::Migration
  def up
    create_table :journals do |t|
      t.string :name
      t.references :journal_entries
      t.belongs_to :user

      t.timestamps
    end
  end

  def down
    drop_table :journals
  end
end
