class CreateBooks < ActiveRecord::Migration
  def up
    create_table :books do |t|
      t.string :title
      t.text   :description
      t.belongs_to :user

      t.timestamps
    end

    add_attachment :books, :cover_image
  end

  def down
    drop_table :books
  end
end
