class UserCoursesController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :user_course

  before_filter :load_general_course_data, only: [:show]

  def show
    @user_course.create_all_std_tags
    @std_tags = @user_course.std_tags.sort_by { |std_tag| std_tag.tag.tag_group_id || 0 }
  end
end
