class ForumParticipationController < ApplicationController
  load_and_authorize_resource :course

  before_filter :load_general_course_data, only: [:manage]

  def manage
    @from_date = params[:from] || '01-10-2013'
    @to_date = params[:to] || '30-11-2013'
    from_date_db = parse_start_date(@from_date)
    to_date_db = parse_end_date(@to_date)

    @students_courses = @course.user_courses.student.order('lower(name)')
    category ||= Forem::Category.find(@course.id)
    result = Forem::Forum.
        joins(topics: :posts).
        where('category_id = ?', category.id)
    if (from_date_db)
      result.where('forem_posts.created_at >= ?', from_date_db)
    end
    if (to_date_db)
      result.where('forem_posts.created_at <= ?', to_date_db)
    end
    result = result.
        select('COUNT(*) as post_count, forem_posts.user_id').
        group('forem_posts.user_id')
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

  def parse_start_date(date)
    result = date_dmy_to_db(date)
    result ? result + ' 00:00:00' : false
  end

  def parse_end_date(date)
    result = date_dmy_to_db(date)
    result ? result + ' 23:59:59' : false
  end

  def date_dmy_to_db(date)
    begin
      if date.nil?
        ""
      else
        Date.strptime(date, '%d-%m-%Y').strftime('%Y-%m-%d')
      end
    rescue
      false
    end
  end
end
