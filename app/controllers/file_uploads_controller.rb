class FileUploadsController < ApplicationController
  load_and_authorize_resource :course

  def create
    file_upload = FileUpload.create({
      creator: current_user,
      course: @course,
      file: params[:files].first
    })

    puts request
    puts request.scheme
    puts request.host_with_port

    if file_upload.save
      resp = {
        url: "#{request.scheme}://#{request.host_with_port}#{file_upload.file.url}"
      }
      respond_to do |format|
        format.html { render json: resp }
      end
    end
  end
end
