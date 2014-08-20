class Photo < ActiveRecord::Base
  attr_accessible :image, :take_at, :latitude, :longitude, :description, :user
  belongs_to :user
  has_attached_file :image,
    :styles => {:medium => '300x300>', :thumb => '100x100>'},
    :path => ':rails_root/private/:rails_env/photos/:id/:style/:basename.:extension'

  validates_attachment_content_type :image, :content_type => %w(image/jpg image/jpeg image/png image/gif)

  def medium_url
    '/photos/show/' + self.id.to_s
  end
end
