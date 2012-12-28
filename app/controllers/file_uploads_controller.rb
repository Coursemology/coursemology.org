class FileUploadsController < ApplicationController

  def create
    if !current_user
      respond_to do |format|
        format.html { render text: "Unauthorized access!" }
      end
    end

    if params[:course_id]
      @course = Course.find(params[:course_id])
      authorize! :upload_file, @course
    end

    file_upload = FileUpload.create({
      creator: current_user,
      course: @course,
      file: params[:files].first
    })

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
