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
    if date != nil
      logger.info('Filter entries with: ' + search_query)
      entries = JournalEntry.where('created_at >= :date', date: date).paginate(:page => page, :per_page => per_page).order('created_at')
    else
      entries = JournalEntry.paginate(:page => page, :per_page => per_page).order('created_at')
    end
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
    if date != nil
      photos = Photo.where('taken_at >= :date', date: date).paginate(:page => params[:page], :per_page => 24).order('taken_at')
    else
      photos = Photo.paginate(:page => page, :per_page => per_page).order('taken_at')
    end
    @photos = []
    photos.each do |p|
      @photos.push(
          'id'    => p.id,
          'url'   => p.medium_url,
          'date'  => p.taken_at.to_i
      )
    end

    render json: (JSON.generate(@photos))
  end
end
