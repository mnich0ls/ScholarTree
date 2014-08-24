class Book < ActiveRecord::Base

  @@cover_image_style_map = {
      'thumb'     => :thumb,
      'medium'    => :medium,
      'large'     => :large,
      'original'  => :original,
      nil         => :medium

  }

  attr_accessible :title, :cover_image, :description, :user
  belongs_to :user
  has_attached_file :cover_image,
                    :styles => {:medium => '300x300>', :thumb => '100x100>'}

  validates_attachment_content_type :cover_image, :content_type => %w(image/jpg image/jpeg image/png image/gif)

  def cover_image_url_for_style(style)
    '/books/show/' + self.id.to_s + '?style=' + self.style_for(style).to_s
  end

  def style_for(style)
    style = @@cover_image_style_map[style]
    if style == nil
      return :medium
    end
    style
  end

end