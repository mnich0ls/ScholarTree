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
      date = Date.today - 30
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
    date = Chronic.parse(search_query)

    if date == nil
      date = Date.today - 30
    end

    photos = Photo.where('taken_at >= :date AND user_id = :user_id',
                         date: date, user_id: current_user)
    .paginate(:page => page, :per_page => per_page)
    .order('taken_at')

    accessible_styles = {
        'thumb'     => :thumb,
        'medium'    => :medium,
        'large'     => :large,
        'original'  => :original,
        nil         => :medium

    }
    style = accessible_styles[params['size']]
    @photos = []
    photos.each do |p|
      @photos.push(
          'id'          => p.id,
          'url'         => p.medium_url,
          'date'        => p.taken_at.to_i,
          'width'       => p.image.width(style),
          'height'      => p.image.height(style),
          'description' => p.description
      )
    end

    render json: (JSON.generate(@photos))
  end
end
