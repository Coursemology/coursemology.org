class GuildController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :guild, through: :course
  before_filter :load_general_course_data, only: [:index, :view, :manage, :new, :edit] #for pages that client sees

  def index
    # load all the user exp and calculate the average exp
  end

  def view
  end

  def manage
    @student_courses = @course.user_courses.student.where(is_phantom: false).order('lower(name)')
  end

  def new
    @guild = Guild.new(course_id: curr_user_course.course_id)
    respond_to do |format|
      format.html
    end
  end

  def edit
  end

  def edit_user
    user_course = UserCourse.find(params[:user_course][:user_course])
    guild_user = user_course.has_guild? ? user_course.guild_user : GuildUser.new(user_course_id: user_course.id)
    guild_user.guild_id = params[:guild_id][0] == -1 ? nil : params[:guild_id][0]

    respond_to do |format|
      if guild_user.save
        format.html { redirect_to course_manage_guild_url(@course),
                                  notice: "#{user_course.name}'s guild has been updated." }
      else
        format.html { render action: "manage" }
      end
    end
  end

  def update
    respond_to do |format|
      if @guild.update_attributes(params[:guild])
        format.html { redirect_to course_guild_url(@course),
                                  notice: "The Guild '#{@guild.name}' has been updated." }
      else
        format.html { render action: "edit" }
      end
    end
  end

  def create
    respond_to do |format|
      if @guild.save
        format.html { redirect_to course_guild_description_path @course,
                                  notice: "The Guild '#{@guild.name}' has been created." }
      end
      format.html { render action: "new" }
    end
  end

  def destroy
    @guild.destroy
    respond_to do |format|
      format.html { redirect_to course_guild_url,
                     notice: "The Guild '#{@guild.name}' has been removed." }
    end
  end
end
