class ForumParticipationController < ApplicationController
  load_and_authorize_resource :course
  #load_and_authorize_resource :user_course

  before_filter :load_general_course_data, only: [:manage, :individual]

  def manage
    @from_date = params[:from] || '01-10-2013'
    @to_date = params[:to] || '30-11-2013'
    from_date_db = parse_start_date(@from_date)
    to_date_db = parse_end_date(@to_date)

    @students_courses = @course.user_courses.student
    category = Forem::Category.find(@course.id)
    result = Forem::Post
      .joins(topic: :forum)
      .where(forem_forums: {category_id: category.id})#.includes(:topic)
      .joins(user: :user_courses)
      .where(user_courses: {course_id: @course.id, is_phantom: false, role_id: Role.student.first})
      .joins('LEFT JOIN levels ON levels.id = user_courses.level_id')
    if (from_date_db)
      result = result.where('forem_posts.created_at >= ?', from_date_db)
    end
    if (to_date_db)
      result = result.where('forem_posts.created_at <= ?', to_date_db)
    end
    @post_count = result
        .select('COUNT(*) as post_count, forem_posts.user_id as user_id, user_courses.exp as exp, ' +
               'user_courses.name as name, levels.level as level, user_courses.id as user_course_id')
       .group('forem_posts.user_id')
       .order('post_count')
  end


  def individual

    @user_course = @course.user_courses.find(params[:poster_id])

    @from_date =  params[:from_date] || '01-10-2013'
    @to_date = params[:to_date] || '30-10-2013'
    from_date_db = parse_start_date(@from_date)
    to_date_db = parse_end_date(@to_date)

    category = Forem::Category.find(@course.id)
    result = Forem::Post
        .joins(topic: :forum).where(forem_forums: {category_id: category.id})#.includes(:topic)
    if (from_date_db)
      result = result.where('forem_posts.created_at >= ?', from_date_db)
    end
    if (to_date_db)
      result = result.where('forem_posts.created_at <= ?', to_date_db)
    end
    @result = result.where('forem_posts.user_id = ?', @user_course.user_id)
    puts @result.to_sql
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

  def date_dmy_to_readable_format(date)
    Date.strptime(date, '%d-%m-%Y').strftime('%e %b')
  end
  helper_method :date_dmy_to_readable_format
end
