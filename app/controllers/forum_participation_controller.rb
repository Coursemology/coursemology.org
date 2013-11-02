class ForumParticipationController < ApplicationController
  load_and_authorize_resource :course

  before_filter :load_general_course_data, only: [:manage]

  def manage
    @from_date = params[:from] || '01-10-2013'
    @to_date = params[:to] || '30-11-2013'
    from_date_db = date_dmy_to_ymd(@from_date) + ' 00:00:00'
    to_date_db = date_dmy_to_ymd(@to_date) + ' 23:59:59'

    @students_courses = @course.user_courses.student.order('lower(name)')
    category ||= Forem::Category.find(@course.id)
    result = Forem::Forum.
        joins(topics: :posts).
        where('category_id = ? AND forem_posts.created_at >= ? AND forem_posts.created_at <= ?',
              category.id, from_date_db, to_date_db).select('COUNT(*) as post_count, forem_posts.user_id').group('forem_posts.user_id')
    @post_count = {}
    result.each {|i| @post_count[i.user_id] = i.post_count}
    @range_selection = {}

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

  private
  def date_dmy_to_ymd(date)
    if date.nil?
      ""
    else
      Date.strptime(date, '%d-%m-%Y').strftime('%Y-%m-%d')
    end
  end
end
