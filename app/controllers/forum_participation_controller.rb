class ForumParticipationController < ApplicationController
  load_and_authorize_resource :course

  before_filter :load_general_course_data, only: [:manage]

  def manage
    @students_courses = @course.user_courses.student.order('lower(name)')
    category ||= Forem::Category.find(@course.id)
    posts ||= Forem::Forum.joins(topics: :posts).where('category_id' => category.id)
    result = posts.select('COUNT(*) as post_count, forem_posts.user_id').group('forem_posts.user_id')
    @post_count = {}
    result.each {|i| @post_count[i.user_id] = i.post_count}
    @range_selection = {}

    @from_date = params[:from] || '11-01-2013'
    @to_date = params[:to] || '31-01-2013'
    sort_key = ''

    if sort_column == 'Name'
      sort_key = 'lower(name) '
    end

    if sort_column == 'Level'
      sort_key = 'level_id '
    end

    if sort_column == 'Exp'
      sort_key = 'exp '
    end

    if  sort_column
      @students_courses = @course.user_courses.student.order(sort_key + sort_direction)
    end
  end


  def student_posts

  end
end
