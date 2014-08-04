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
    unless current_user
      respond_to do |format|
        format.html { render text: "Unauthorized access!" }
      end
    end

    if params[:course_id]
      @course = Course.find(params[:course_id])
      authorize! :upload_file, @course
    end
    resources = [Assessment, Assessment::Submission]
    owner = nil

    resources.each do |r|
      id = params["#{r.name.underscore.gsub('/', '_')}_id"]
      next if params[id]
      owner = r.find_by_id(id)
      break if owner
    end


    file = params[:files].class == Array ? params[:files].first : params[:files]
    file_upload = FileUpload.create({
                                        creator: current_user,
                                        owner: owner || @course,
                                        file: file
                                    })

    if file_upload.save

      #save to local folder, in case the file will be included for code question.
      #TODO: improve, should only save coding related file to local disk
      if params[:assessment_id]
        PythonEvaluator.create_local_file_for_asm(owner, file_upload)
      end

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
            url: file_upload.file_url,
            id: file_upload.id
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
    owner = nil
    if params[:assessment_id]
      owner = Assessment.find(params[:assessment_id])
    elsif params[:assessment_submission_id]
      owner = Assessment::Submission.find(params[:assessment_submission_id])
    elsif params[:survey_question_id]
      owner = SurveyQuestion.find(params[:survey_question_id])
    end

    @uploads = owner ? owner.files.order(:is_public).reverse : []

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
    if @upload.owner.class == SurveyQuestionOption
      @upload.owner.destroy
    end
    @upload.destroy

    respond_to do |format|
      #format.html { redirect_to uploads_url }
      format.json { head :no_content }
    end
  end

  def toggle_access
    @upload = FileUpload.find(params[:id])
    @upload.is_public = !@upload.is_public

    respond_to do |format|
      #format.html { redirect_to uploads_url }
      if @upload.save
        format.json { render json: {is_public: @upload.is_public } }
      end
    end
  end

  def show
  end

end
