class GuildsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :guild, through: :course

  before_filter :load_general_course_data, only: [:index, :view, :manage, :new, :edit] #for pages that client sees

  def index
    # load all the user exp and calculate the average exp
    if @guilds
      @guild_results = []
      @guilds.each do |guild|
        guild_info = {}
        guild_info[:name] = guild.name
        guild_info[:id] = guild.id
        guild_info[:description] = guild.description
        guild_users = guild.guild_users.map { |x| { :name => x.user_course.name,
                                                    :exp => x.user_course.exp,
                                                    :profile_pic => x.user_course.user.get_profile_photo_url,
                                                    :level => x.user_course.level ? x.user_course.level.get_title : 'Level 0'  } }
        guild_info[:users] = guild_users.sort { |usr1, usr2| usr2[:exp] <=> usr1[:exp] }
        guild_info[:avg_exp] = guild_users.count == 0 ? 0 : guild_users.sum { |user| user[:exp] } / guild_users.count

        @guild_results << guild_info
      end
      @guild_results.sort! { |guild1, guild2| guild2[:avg_exp] <=> guild1[:avg_exp] }
    end
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
    # Get usercourse from form data. Determine whether there is a need to create a GuildUser instance
    user_course = UserCourse.find(params[:user_course][:user_course])
    guild_user = user_course.has_guild? ? user_course.guild_user : GuildUser.new(user_course_id: user_course.id)

    # Check to see if user is to be unassigned. A value of -1 means no guild.
    guild_user.guild_id = params[:guild_id][0] == -1 ? nil : params[:guild_id][0]

    respond_to do |format|
      if guild_user.save
        format.html { redirect_to course_guild_users_path(@course),
                                  notice: "#{user_course.name}'s guild has been updated." }
      else
        format.html { render action: "manage" }
      end
    end
  end

  def update
    respond_to do |format|
      if @guild.update_attributes(params[:guild])
        format.html { redirect_to course_guild_management_path(@course),
                                  notice: "The Guild '#{@guild.name}' has been updated." }
      else
        format.html { render action: "view" }
      end
    end
  end

  def create
    respond_to do |format|
      if @guild.save
        format.html { redirect_to course_guild_management_path @course,
                                  notice: "The Guild '#{@guild.name}' has been created." }
      end
      format.html { render action: "new" }
    end
  end

  def destroy
    @guild.destroy
    respond_to do |format|
      format.html { redirect_to course_guilds_url,
                     notice: "The Guild '#{@guild.name}' has been removed." }
    end
  end
end
