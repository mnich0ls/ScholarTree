class MediaSearchController < AuthenticatedController
  SEARCH_URL = 'https://itunes.apple.com/search?'
  LOOKUP_URL = 'https://itunes.apple.com/lookup?'

  def show
    @query = params['query']
    api_params = {
        :term => @query,
        :limit => 25
    }
    if params['type'] != nil
      api_params[:media] = 'ebook'
    end
    response = JSON.parse(open(MediaSearchController::SEARCH_URL + api_params.to_query) { |io| data = io.read })
    @results = []
    response['results'].each do |r|
      artwork_url = r['artworkUrl100']

      result = {}
      result[:artworkUrl]   = artwork_url.gsub(/100x100/, '600x600')
      result[:description]  = r['trackName']
      result[:thumbnailUrl] = r['artworkUrl100']

      if r['wrapperType'] != nil
        result[:type] = r['wrapperType']
      elsif r['kind'] != nil
        result[:type] = r['kind']
      end

      @results.push(result)
    end
  end

  def query
  end

  def add_book
    api_params = {
        :id     => params['id']
    }
    response = JSON.parse(open(MediaSearchController::LOOKUP_URL + api_params.to_query) { |io| data = io.read })

    if response['results'].length == 0
      logger.error('No book found with id: ' + params['id'])
    else
      book = response['results'][0]
      if book['kind'] != 'ebook'
        logger.error('Expected book. Found: ' + book['kind'])
      else
        artwork_url  = book['artworkUrl100'].gsub(/100x100/, '600x600')
        title        = book['trackName']
        description  = book['description']

        book = Book.new(:user => current_user, :title => title,
                        :description => description,
                        :cover_image => open(artwork_url))
        book.save!
      end
    end
  end
end