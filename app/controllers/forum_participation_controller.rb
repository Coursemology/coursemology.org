class ForumParticipationController < ApplicationController
  load_and_authorize_resource :course
  #load_and_authorize_resource :user_course

  before_filter :load_general_course_data, only: [:manage, :individual]

  def manage
    @from_date = params[:from]
    @to_date = params[:to]

    from_date_db = parse_start_date(@from_date)
    to_date_db = parse_end_date(@to_date)
    @weekly = params[:weekly].blank? ? 100 : params[:weekly] # defaults to 100 EXP per week for now
    @actual_cap = actual_exp_cap(@from_date, @to_date, @weekly.to_i)

    @students_courses = @course.user_courses.real_students
    category = Forem::Category.find(@course.id)
    result = Forem::Post
      .joins(topic: :forum)
      .where(forem_forums: {category_id: category.id})
      .includes(:votes)
    if (from_date_db)
      result = result.where('forem_posts.created_at >= ?', from_date_db)
    end
    if (to_date_db)
      result = result.where('forem_posts.created_at <= ?', to_date_db)
    end

    std_courses = @students_courses.collect {|i| i} # array of UserCourses

    @post_count = Array.new # array of hashes

    result.each do |post| # to save memory, this can be changed to find_each
      if std_index = std_courses.index {|i| i.user_id == post.user_id}
        if post_index = @post_count.index {|i| i[:std_course_id] == std_courses[std_index].id}
          @post_count[post_index][:count] += 1
          @post_count[post_index][:likes] += post.likes.size
        else
          @post_count << {std_course_id: std_courses[std_index].id,
                          name: std_courses[std_index].name,
                          level: std_courses[std_index].level ? std_courses[std_index].level.level : 0,
                          exp: std_courses[std_index].exp,
                          likes: post.likes.size,
                          count: 1}
        end
      end
    end

    @post_count.sort! {|a, b| post_score(b) <=> post_score(a) }

    prev_score = -1
    prev_exp = -1
    @post_count.each_with_index do |student, index|
      if post_score(student) == prev_score
        # student with same score must have the same EXP to be fair
        student[:proposed_exp] = prev_exp
      else
        # divides students up to 10 groups, top 10% gets full exp, top 20% gets 90% exp... last 10% gets 10% exp
        student[:proposed_exp] = ((1.0 - index.to_f / @post_count.size).round(1) * @actual_cap).to_i
        prev_score = post_score(student)
        prev_exp = student[:proposed_exp]
      end
    end
  end

  def individual

    @user_course = @course.user_courses.find(params[:poster_id])

    @from_date =  params[:from_date]
    @to_date = params[:to_date]
    from_date_db = parse_start_date(@from_date)
    to_date_db = parse_end_date(@to_date)

    category = Forem::Category.find(@course.id)
    result = Forem::Post
        .includes(topic: :forum).where(forem_forums: {category_id: category.id})
        .includes(:votes)
    if (from_date_db)
      result = result.where('forem_posts.created_at >= ?', from_date_db)
    end
    if (to_date_db)
      result = result.where('forem_posts.created_at <= ?', to_date_db)
    end
    result = result.where('forem_posts.user_id = ?', @user_course.user_id)

    @result = Array.new

    result.each do |post|
      @result << {subject: post.topic.subject,
                  text: post.text,
                  likes: post.likes.size,
                  created: post.created_at,
                  id: post.id,
                  topic_id: post.topic.id,
                  forum: post.topic.forum
                  }
    end

    @result.sort! {|a, b| b[:likes] <=> a[:likes]}
    puts @result.length
    if params[:limit]
      @result = @result.slice(0, params[:limit].to_i)
    end
    puts @result.length

    @is_raw = params[:raw] ? true : false
    if (@is_raw)
      render :layout => false
    end
  end

  def date_dmy_to_readable_format(date)
    begin
      Date.strptime(date, '%d-%m-%Y').strftime('%e %b')
    rescue
      false
    end

  end
  helper_method :date_dmy_to_readable_format

  private

  def post_score(student)
    student[:count] + student[:likes]
  end

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
        nil
      else
        Date.strptime(date, '%d-%m-%Y').strftime('%Y-%m-%d')
      end
    rescue
      false
    end
  end

  def number_of_days(from, to)
    begin
      from_date = Date.strptime(from, '%d-%m-%Y')
      to_date = Date.strptime(to, '%d-%m-%Y')
      to_date - from_date + 1
    rescue
      -1
    end
  end

  def actual_exp_cap(from, to, weekly)
    days = number_of_days(from, to).to_i
    days > 0 ? (weekly * days / 7).floor : weekly
  end

end
