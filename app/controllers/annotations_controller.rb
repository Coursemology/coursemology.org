class AnnotationsController < ApplicationController
  load_and_authorize_resource :course

  include ApplicationHelper
  include ActionView::Helpers::DateHelper


  def create
    @annotation = Annotation.new(params[:annotation])
    @annotation.user_course = curr_user_course

    authorize! :read, @annotation.annotable
    if @annotation.save
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
    @annotations = Annotation.includes(:user_course).find_all_by_annotable_id_and_annotable_type(params[:annotation][:annotable_id],params[:annotation][:annotable_type])
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
