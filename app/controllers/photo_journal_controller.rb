class PhotoJournalController < AuthenticatedController
  def show
    entries = JournalEntry.paginate(:page => params[:page], :per_page => 3)
    @entries = []
    entries.each do |entry|
      @entries.push(
        'title' => entry.description,
        'snippet' => entry.snippet.encode('UTF-8', {:invalid => :replace, :undef => :replace, :replace => '?'})
      )
    end
    render layout: 'full_screen'
  end

  def entries
    entries = JournalEntry.paginate(:page => params[:page], :per_page => 24).order("created_at")
    @entries = []
    entries.each do |e|
      @entries.push(
          'title'   => e.description,
          'snippet' => e.snippet.encode('UTF-8', {:invalid => :replace, :undef => :replace, :replace => '?'}),
          'date'    => e.created_at.to_time.to_i
      )
    end

    render json: (JSON.generate(@entries))
  end

  def photos
    photos = Photo.paginate(:page => params[:page], :per_page => 24).order("created_at")
    @photos = []
    photos.each do |p|
      @photos.push(
          'url'   => p.medium_url,
          'date'  => p.taken_at.to_i
      )
    end

    render json: (JSON.generate(@photos))
  end
end
