require 'chronic'

class PhotoJournalController < AuthenticatedController
  def show
    render layout: 'full_screen'
  end

  def entries
    search_query  = params['search-query']
    page          = params[:page]
    per_page      = 24
    date = Chronic.parse(search_query)

    if date == nil
      date = self.default_date
    end

    logger.info(date)

    entries = JournalEntry.joins(:journal)
    .where('journals.user_id' => current_user)
    .where('journal_entries.created_at >= :date', date: date)
    .paginate(:page => page, :per_page => per_page)
    .order('journal_entries.created_at')

    @entries = []
    entries.each do |e|
      @entries.push(
          'id'      => e.id,
          'type'    => 'entry',
          'title'   => e.description,
          'snippet' => e.snippet.encode('UTF-8', {:invalid => :replace, :undef => :replace, :replace => '?'}),
          'date'    => e.created_at.to_time.to_i
      )
    end

    render json: (JSON.generate(@entries))
  end

  def photos
    search_query  = params['search-query']
    page          = params[:page]
    per_page      = 24
    date          = Chronic.parse(search_query)

    if date == nil
      date = self.default_date
    end

    photos = Photo.where('taken_at >= :date AND user_id = :user_id',
                         date: date, user_id: current_user)
    .paginate(:page => page, :per_page => per_page)
    .order('taken_at')

    style = params['size']
    modal_style = params['modal_size']

    @photos = []
    photos.each do |p|
      @photos.push(
          'id'          => p.id,
          'type'        => 'photo',
          'url'         => p.image_url_for_style(style),
          'modalUrl'    => p.image_url_for_style(modal_style),
          'date'        => p.taken_at.to_i,
          'dateString'  => p.taken_at.strftime("%A %B %d %Y"),
          'width'       => p.image.width(style),
          'height'      => p.image.height(style),
          'modalWidth'  => p.image.width(modal_style),
          'modalHeight' => p.image.height(modal_style),
          'description' => p.description
      )
    end

    render json: (JSON.generate(@photos))
  end

  def books
    search_query    = params['search-query']
    page            = params[:page]
    per_page        = 24
    date            = Chronic.parse(search_query)

    if date == nil
      date = self.default_date
    end

    books = Book.where('created_at >= :date AND user_id = :user_id',
                      date: date, user_id: current_user)
    .paginate(:page => page, :per_page => per_page)
    .order('created_at')

    style       = params['size']
    modal_style = params['modal_size']

    logger.info(modal_style)

    @books = []
    books.each do |b|
      @books.push(
          'id'          => b.id,
          'type'        => 'book',
          'url'         => b.cover_image_url_for_style(style),
          'modalUrl'    => b.cover_image_url_for_style(modal_style),
          'width'       => b.cover_image.width(style),
          'height'      => b.cover_image.height(style),
          'modalWidth'  => b.cover_image.width(modal_style),
          'modalHeight' => b.cover_image.height(modal_style),
          'date'        => b.created_at.to_i,
          'dateString'  => b.created_at.strftime("%A %B %d %Y"),
          'title'       => b.title,
          'description' => b.description.to_s
      )
    end

    render json: (JSON.generate(@books))
  end

  def default_date
    Date.today - 30
  end
end
