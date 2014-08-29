class AddSourceToMedia < ActiveRecord::Migration
  def up
    change_table :media do |t|
      t.string :source
    end
  end

  def down
    remove_column :media, :source
  end
end
