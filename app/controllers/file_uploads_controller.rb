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
      puts file_upload.to_json
      if file_upload.file_content_type == 'application/zip'
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
        format.html { render json: resp }
      end
    end
  end
end
