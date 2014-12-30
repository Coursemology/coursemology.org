class Assessment::ScribingQuestionsController < Assessment::QuestionsController

  def create
    assign_params
    extract_tags
    @question.creator = current_user
    qa = @assessment.question_assessments.new
    qa.question = @question.question
    qa.position = @assessment.questions.count
    uploaded_file_object = params[:assessment_scribing_question][:document]
    allowed_img_types = ['image/gif', 'image/png', 'image/jpeg', 'image/pjpeg']

    #special handling for PDF files
    if uploaded_file_object && uploaded_file_object.content_type.downcase == 'application/pdf'
      png_converter = PngConvert.new(uploaded_file_object)
      png_files = png_converter.convert_to_png
      png_success = false   #track success of each png file upload

      # Create questions for them, upload the files and save them
      png_files.each do |png_file|
        page_question = Assessment::ScribingQuestion.new

        # set params for the scribing question for this png file
        page_question.title = png_file
        page_question.description = @question.description
        page_question.max_grade = @question.max_grade
        page_question.creator = current_user

        # create question_assessment
        qn_assessment = @assessment.question_assessments.new
        qn_assessment.question = page_question.question
        qn_assessment.position = @assessment.questions.count

        # make png_file pretend to be an uploaded file
        fake_upload_file = ActionDispatch::Http::UploadedFile.new(:tempfile => File.new(png_file),
                                                                  :filename => png_file)

        file_upload = FileUpload.create({creator: current_user,
                                      owner: page_question,
                                      file: fake_upload_file
                                      })
        png_success = file_upload.save

        # save question and question_assessment to db
        page_question.save
        qn_assessment.save
      end

      png_converter.clean_up

    elsif uploaded_file_object && (allowed_img_types.include? uploaded_file_object.content_type.downcase)
      file_upload = FileUpload.create({creator: current_user,
                                       owner: @question,
                                       file: uploaded_file_object
                                       })
      file_save_success = file_upload.save
    else
      file_save_success = false
    end
    
    respond_to do |format|
      # if all the png files are uploaded properly, don't save the current question
      # and question_assessment. Individual qns and qn_ass have been created for
      # each png file and the 'dummy' one can be discarded.
      #
      # The 'if' condition uses short circuiting when all png files
      # are successfully uploaded.
      #
      # if it's a single file of an allowed type, save the current qn and qn_ass. 
      #
      # file_save_success MUST be checked first, or invalid questions and questions_assessments
      # will be created.
      if png_success || (file_save_success && @question.save && qa.save)
        format.html { redirect_to url_for([@course, @assessment.as_assessment]),
                      notice: 'Question has been added.' }
        format.json { render json: @question, status: :created, location: @question }
      else
        format.html { redirect_to new_course_assessment_assessment_scribing_question_path(@course, @assessment),
                      :flash => { :error => 'File type not supported.' } }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @question.update_attributes(params[:assessment_scribing_question])
        format.html { redirect_to url_for([@course, @assessment.as_assessment]),
                                  notice: 'Question has been updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end


  protected

  def build_resource
    if params[:action] == 'create'
      @question = Assessment::ScribingQuestion.new
    elsif params[:action] == 'update'
      @question = Assessment::ScribingQuestion.find(params[:id])
    else
      super
    end
  end


  private

  def assign_params
    form_params = params['assessment_scribing_question']
    @question.title = form_params[:title]
    @question.description = form_params[:description]
    @question.max_grade = form_params[:max_grade]
  end

end
