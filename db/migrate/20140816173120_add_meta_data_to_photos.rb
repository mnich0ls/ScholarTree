class AddMetaDataToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :image_meta, :text
  end
end
