class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
      t.string :title
      t.text :description
      t.datetime :taken_at
      t.decimal :latitude, :precision => 10, :scale => 6
      t.decimal :longitude, :precision => 10, :scale => 6
      t.belongs_to :user

      t.timestamps
    end
    
    add_attachment :photos, :image
  end

  def down
    drop_tables :photos
  end
end
