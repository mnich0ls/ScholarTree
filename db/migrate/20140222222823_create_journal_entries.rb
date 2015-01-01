class CreateJournalEntries < ActiveRecord::Migration
  def up
    create_table :journal_entries do |t|
      t.text :entry
      t.string :description
      t.references :journal

      t.timestamps
    end
  end

  def down
    drop_table :journal_entries
  end
end
