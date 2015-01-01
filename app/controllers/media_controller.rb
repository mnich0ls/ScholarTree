class MediaController < AuthenticatedController
  SEARCH_URL = 'https://itunes.apple.com/search?'
  LOOKUP_URL = 'https://itunes.apple.com/lookup?'

  @@image_style_map = {
      'thumb'   => :thumb,
      'medium'  => :medium,
      'full'    => nil,
      nil       => :medium # default
  }

  @@media_type_map = {
      'ebook'            => 'book',
      'album'           => 'album',
      'movie'           => 'movie',
      'feature-movie'   => 'movie',
      'podcast'         => 'podcast',
      'podcast-episode' => 'podcast-episode',
      'music'           => 'music',
      'song'            => 'song',
      'audiobook'       => 'audiobook',
      'tv-episode'      => 'tv-episode',
      'artist'          => 'artist'
  }


  def add
  end

  def image
    @Media = Media.find(params[:id])
    if @Media.user != current_user
      raise "error"
    end

    send_file @Media.image.path(self.get_style([params['style']])), disposition: 'inline'
  end

  def show
    @media = Media.find(params[:id])
    logger.info(@media.title)
  end

  def query
    @query = params['query']
    api_params = {
        :term => @query,
        :limit => 25
    }
    if params['type'] != nil and params['type'] != 'all'
      api_params[:media] = params['type']
    end
    response = JSON.parse(open(MediaController::SEARCH_URL + api_params.to_query) { |io| data = io.read })
    @results = []
    response['results'].each do |r|
      result = {}
      result[:artworkUrl]   = r['artworkUrl100']
      result[:title]        = r['trackName']
      result[:thumbnailUrl] = r['artworkUrl100']
      result[:identifier]   = r['trackId'].to_s
      result[:source]       = 'APPLE'
      result[:id]           = result[:source] + result[:identifier]
      result[:owned]        = is_media_owned('APPLE', r['trackId'])



      if r['kind'] != nil
        result[:type] = @@media_type_map[r['kind']]
      elsif r['wrapperType'] != nil
        result[:type] = @@media_type_map[r['wrapperType']]
      end

      @results.push(result)
    end

    render json: JSON.generate(@results)
  end

  def new
    params.permit(:identifier, :source)
    api_params = {
        :id => params['identifier']
    }

    unless is_media_owned(params['source'], params['id'])
      response = JSON.parse(open(MediaController::LOOKUP_URL + api_params.to_query) { |io| data = io.read })

      if response['results'].length == 0
        logger.error('No media found with identifier: ' + params['identifier'])
      else
        media = response['results'][0]
        artwork_url  = media['artworkUrl100'].gsub(/100x100/, '600x600')
        title        = media['trackName'].encode('UTF-8')
        description  = media['description'] != nil ? media['description'].encode('UTF-8') : nil
        type         = self.get_type(media['kind'])
        identifier   = media['trackId']

        logger.info(type)

        medium = Media.new(:user => current_user, :title => title,
                           :description => description, :type => type,
                           :source => 'APPLE', :identifier => identifier,
                           :image => open(artwork_url))
        medium.save!
      end
    else
      medium = Media.where({:identifier => params['id'], :source => 'APPLE'}).first
    end
    render json: JSON.generate({identifier: params['identifier']})
  end

  def get_style(style)
    style = @@image_style_map[style]
    if style == nil
      return :medium
    end
    style
  end

  def get_type(type)
    type = @@media_type_map[type]
    if type == nil
      return 'unknown'
    end
    type
  end

  def is_media_owned(source, id)
    media = Media.where({:identifier => id, :source => source})
    if media.length > 0
      true
    else
      false
    end
  end
end