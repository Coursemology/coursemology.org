class AnnotationsController < ApplicationController
  load_and_authorize_resource :course

  include ApplicationHelper
  include ActionView::Helpers::DateHelper


  def create
    @annotation = Annotation.new(params[:annotation])
    @annotation.user_course = curr_user_course
    std_course = @annotation.annotable.std_course
    to_notify = [std_course]

    if std_course == curr_user_course
      to_notify = std_course.get_staff_incharge
    end

    sub = Assessment::Submission.find_by_id(params[:submission_id])

    authorize! :read, @annotation.annotable
    if @annotation.save
      # TODO: fix the notify_user function
      # currently this method wouldn't find the correct users to notify, marking pending wouldn't work either
      # I think it can be resolved by adding the annotable to the CommentTopic list. However, need to avoid
      # it being removed (when comments count == 0, the topic is removed -- see CommentController#destroy)
      if sub.assessment.published?
        @annotation.notify_user(to_notify, sub.assessment, course_assessment_submission_url(@course, sub.assessment, sub))
      end
      respond_to do |format|
        format.json {render json: get_all}
      end
    end
  end

  def index
    respond_to do |format|
      format.json {render json: get_all}
    end
  end

  def destroy
    @annotation = Annotation.where(id: params[:id]).first
    authorize! :manage, @annotation
    if @annotation
      @annotation.destroy
    end
    respond_to do |format|
      format.json {render json: {ststus: 'OK'} }
    end
  end

  def update
    @annotation = Annotation.where(id: params[:id]).first
    authorize! :manage, @annotation

    if @annotation
      @annotation.text = params[:text]
      @annotation.save
    end
    respond_to do |format|
      format.json {render json: {c: style_format(@annotation.text, false), o: @annotation.text }}
    end
  end

  private
  def get_all
    @annotations = Annotation.find_all_by_annotable_id_and_annotable_type(params[:annotation][:annotable_id],params[:annotation][:annotable_type])
    responds = []
    @annotations.each do |anno|
      edit = curr_user_course.is_staff? || (curr_user_course == anno.user_course)
      resp = anno.as_json
      resp[:edit] = edit
      responds.append(resp)
    end
    responds
  end
end
