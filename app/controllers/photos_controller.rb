class PhotosController < AuthenticatedController
  def add
  end

  def create
    @photo = Photo.new(image: params[:file])
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

  def view
    @photo = Photo.find(params[:id])
    if @photo.user != current_user
      raise "error"
    end

    send_file @photo.image.path, disposition: 'inline'
  end
end
