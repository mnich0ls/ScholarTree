class BooksController < AuthenticatedController
  @@cover_image_style_map = {
      'thumb'   => :thumb,
      'medium'  => :medium,
      'full'    => nil,
      nil       => :medium # default
  }
  def show
    @book = Book.find(params[:id])
    if @book.user != current_user
      raise "error"
    end

    send_file @book.cover_image.path(self.get_style([params['style']])), disposition: 'inline'
  end

  def get_style(style)
    style = @@cover_image_style_map[style]
    if style == nil
      return :medium
    end
    style
  end
end