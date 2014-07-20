class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
      t.string :title
      t.text :description
      t.date :date
      t.belongs_to :user

      t.timestamps
    end
    
    add_attachment :photos, :image
  end

  def down
    drop_tables :photos
  end
end
