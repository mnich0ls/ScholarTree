class Media < ActiveRecord::Base

  self.inheritance_column = nil

  @@image_style_map = {
      'thumb'     => :thumb,
      'medium'    => :medium,
      'large'     => :large,
      'original'  => :original,
      nil         => :medium

  }

  attr_accessible :title, :image, :description, :user, :type, :identifier, :source
  belongs_to :user
  has_attached_file :image,
                    :styles => {:medium => '300x300>', :thumb => '100x100>'}

  validates_attachment_content_type :image, :content_type => %w(image/jpg image/jpeg image/png image/gif)

  def style_for(style)
    style = @@image_style_map[style]
    if style == nil
      return :medium
    end
    style
  end

end