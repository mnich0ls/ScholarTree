class Book < ActiveRecord::Base
  attr_accessible :title, :cover_image, :description, :user
  belongs_to :user
  has_attached_file :cover_image,
                    :styles => {:medium => '300x300>', :thumb => '100x100>'}

  validates_attachment_content_type :cover_image, :content_type => %w(image/jpg image/jpeg image/png image/gif)
end