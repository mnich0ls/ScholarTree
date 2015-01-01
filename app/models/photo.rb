class Photo < ActiveRecord::Base

  @@image_style_map = {
      'thumb'     => :thumb,
      'medium'    => :medium,
      'large'     => :large,
      'original'  => :original,
      nil         => :medium

  }

  attr_accessible :image, :taken_at, :latitude, :longitude, :description, :user
  belongs_to :user
  has_attached_file :image,
    :styles => {:medium => '300x300>', :thumb => '100x100>'},
    :path => ':rails_root/private/:rails_env/photos/:id/:style/:basename.:extension'

  validates_attachment_content_type :image, :content_type => %w(image/jpg image/jpeg image/png image/gif)

  def image_url_for_style(style)
    '/photos/show/' + self.id.to_s + '?style=' + self.get_style(style).to_s
  end

  def get_style(style)
    style = @@image_style_map[style]
    if style == nil
      return :medium
    end
    style
  end
end
