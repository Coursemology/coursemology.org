class AnnotationsController < ApplicationController
  load_and_authorize_resource :course

  include ApplicationHelper
  include ActionView::Helpers::DateHelper


  def create
    @annotation = Annotation.new(params[:annotation])
    @annotation.user_course = curr_user_course

    authorize! :read, @annotation.annotable
    if @annotation.save
      @annotation.annotable.notify_user(curr_user_course, @annotation, params[:origin])
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

  private
  def get_all
    @annotations = Annotation.find_all_by_annotable_id_and_annotable_type(params[:annotation][:annotable_id],params[:annotation][:annotable_type])
    responds = []
    @annotations.each do |anno|
      responds.append({
                          c:  style_format(anno.text, false),
                          s:  anno.line_start,
                          e:  anno.line_end,
                          id: anno.id,
                          t:  time_ago_in_words(anno.updated_at),
                          u:  '<span class="student-link"><a href="'+anno.user_course.get_path+'">'+anno.user_course.user.name+'</a></span>',
                          p:  anno.user_course.user.get_profile_photo_url
                      })
    end
    responds
  end
end
