class AddLatLonToJournalEntries < ActiveRecord::Migration
  def up
    change_table :journal_entries do |t|
      t.decimal :latitude, :precision => 10, :scale => 6
      t.decimal :longitude, :precision => 10, :scale => 6
    end
  end

  def down
      remove_column :journal_entries, :latitude, :longitude
  end
end
