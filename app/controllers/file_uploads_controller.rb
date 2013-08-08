class FileUploadsController < ApplicationController
  require 'zip/zipfilesystem'
  require 'fileutils'

  def extract_theme_file(zip_file_path, destination)
    puts 'Zip extract:'
    Zip::ZipFile.open(zip_file_path) do |zip_file|
      zip_file.each do |f|
        puts f.name
        if f.name.start_with?('images') || f.name.start_with?('style.css')
          f_path=File.join(destination, f.name)
          FileUtils.mkdir_p(File.dirname(f_path))
          zip_file.extract(f, f_path) unless File.exist?(f_path)
        end
      end
    end
  end

  def create
    puts "upload file",params
    if !current_user
      respond_to do |format|
        format.html { render text: "Unauthorized access!" }
      end
    end

    if params[:course_id]
      @course = Course.find(params[:course_id])
      authorize! :upload_file, @course
    end

    if params[:file_upload].to_s.size > 0
      file_upload = FileUpload.create({
                                          creator: current_user,
                                          file: params[:file_upload]
                                      })
      puts file_upload
      puts "end here",@course
    else
      file_upload = FileUpload.create({
                                          creator: current_user,
                                          owner: @course,
                                          file: params[:files].first
                                      })
      puts params[:files].first
      puts "end here"
    end

    if file_upload.save
      if file_upload.file_content_type == 'application/zip' && params[:_page_name] == "course_edit"
        course_theme = @course.course_themes.first_or_create
        theme_folder_url = course_theme.get_folder_url
        FileUtils.rm_rf(theme_folder_url)
        extract_theme_file(file_upload.file.path, theme_folder_url)
        resp = {
            url: theme_folder_url
        }
      else
        resp = {
            url: "#{request.scheme}://#{request.host_with_port}#{file_upload.file.url}"
        }
      end
      respond_to do |format|
        if params[:_mode] == "MUL"
          format.html {
            render :json => [file_upload.to_jq_upload].to_json,
                   :content_type => 'text/html',
                   :layout => false
          }
          format.json { render json: {files: [file_upload.to_jq_upload]}, status: :created, location: file_upload }
        else
          format.html { render json: resp }
        end
      end
    end
  end

  def index
    puts "file upload index",params
    owner = nil
    if params[:training_id]
      owner = Training.find(params[:training_id])
    elsif params[:mission_id]
      owner = Mission.find(params[:mission_id])
    elsif params[:submission_id]
      owner = Submission.find(params[:submission_id])
    end

    @uploads = owner ? owner.files : []

    respond_to do |format|
      format.html
      format.json { render json: @uploads.map{|upload| upload.to_jq_upload } }
    end
  end
  def new
    @upload = FileUpload.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @upload }
    end
  end

  def destroy
    @upload = FileUpload.find(params[:id])
    @upload.destroy

    respond_to do |format|
      #format.html { redirect_to uploads_url }
      format.json { head :no_content }
    end
  end

  def show
  end
end
