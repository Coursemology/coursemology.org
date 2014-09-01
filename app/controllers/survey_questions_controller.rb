class SurveyQuestionsController < ApplicationController
  require 'zip/zipfilesystem'
  load_and_authorize_resource :course
  load_and_authorize_resource :survey, through: :course
  load_and_authorize_resource :survey_question, through: :survey

  before_filter :load_general_course_data, only: [:show, :index, :new, :edit]
  require 'digest/md5'

  def new
    @survey_question.type_id = 2
    if params[:section_id]
      @survey_question.survey_section_id = params[:section_id]
    end
  end

  def edit

  end

  def create
    @survey_question.pos = @survey.survey_questions.count

    respond_to do |format|
      if @survey_question.save

        if params[:files]
          process_files(params[:files].values, @survey_question)
        else
          update_options(@survey_question)
        end

        format.html { redirect_to course_survey_url(@course, @survey),
                                  notice: 'New question added.' }
      else
        format.html { render action: "new" }
      end
    end
  end

  def update
    if params[:files]
      process_files(params[:files].values, @survey_question)
    else
      update_options(@survey_question)
    end

    respond_to do |format|
      if @survey_question.update_attributes(params[:survey_question])
        format.html { redirect_to course_survey_url(@course, @survey),
                                  notice: 'Question updated.' }
      else
        format.html { render action: "edit" }
      end
    end

  end

  def process_files(files, question)
    files.each do |id|
      file = FileUpload.where(id:id).first
      if file
        if file.file_content_type.start_with?('image')
          file.preserve_filename = false
          file.save
          create_option(file, question)
        elsif file.file_content_type == 'application/zip'
          #extract_options(file, question)
        end
      end
    end
  end

  def create_option(file, question)
    option = question.options.build
    option.description = File.basename(file.original_name, File.extname(file.original_name)).gsub("_", " ")
    option.save
    file.owner = option
    file.save
  end

  def extract_options(archive, question)
    Zip::ZipFile.open(archive.file_url) do |zip_file|
      zip_file.each do |f|
        if f.name.start_with?('images')
             create_option(f, question)
        end
      end
    end
  end

  def update_options(question)
    if params[:options]
      params[:options].each do |i, option|
        if option.has_key?('id')
          opt = question.options.where(id:option['id']).first
          unless opt
            break
          end
          opt.survey_question = question
          opt.update_attributes(option)
        elsif option['description'] && option['description'].strip != ''
          opt = question.options.build(option)
          opt.save
        end
      end
    end
  end

  def destroy
    @survey_question.destroy
    respond_to do |format|
      format.html { redirect_to course_survey_url(@course, @survey) }
    end
  end

  def reorder
    SurveyQuestion.reordering(params['sortable-item'])
    render nothing: true
  end
end

