class CreateMedia < ActiveRecord::Migration
  def up
    create_table :media do |t|
      t.string :identifier
      t.string :title
      t.string :type
      t.text   :description
      t.belongs_to :user

      t.timestamps
    end

    add_attachment :media, :image
  end

  def down
    drop_table :media
  end
end
