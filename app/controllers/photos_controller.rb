class PhotosController < AuthenticatedController
  def add
  end

  def create
    imageMetaDataExtractor = EXIFR::JPEG.new(params[:file].tempfile.path)
    @photo = Photo.new(image: params[:file])
    @photo.taken_at = imageMetaDataExtractor.date_time
    if imageMetaDataExtractor.exif?
      if imageMetaDataExtractor.gps_longitude != nil and imageMetaDataExtractor.gps_latitude != nil
        lat = imageMetaDataExtractor.gps_latitude.to_f
        if imageMetaDataExtractor.gps_latitude_ref == 'S'
          lat *= -1
        end
        @photo.latitude = lat.to_s
        long = imageMetaDataExtractor.gps_longitude.to_f
        if imageMetaDataExtractor.gps_longitude_ref == 'W'
          long *= -1
        end
        @photo.longitude = long.to_s
      end
    end
    @photo.user = current_user
    if @photo.save!
      respond_to do |format|
        format.json{ render :json => @photo }
      end
    else
      respond_to do |format|
        format.json{ render :json => "test"}
      end
    end
  end

  def show
    @photo = Photo.find(params[:id])
    if @photo.user != current_user
      raise "error"
    end

    send_file @photo.image.path, disposition: 'inline'
  end
end
