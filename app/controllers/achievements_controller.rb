class AchievementsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :achievement, through: :course

  before_filter :load_general_course_data, only: [:show, :index, :new, :edit, :create]
  before_filter :get_fbgraph_for_app, only: [:create, :destroy, :update]
  before_filter :init_badge, only: [:create]

  def index
    #TODO: improve speed
    @achievements = @achievements.includes(:requirements, :as_requirements)
    @ach_paging = @course.paging_pref(Achievement.to_s)
    if @ach_paging.display?
      @achievements = @achievements.page(params[:page]).per(@ach_paging.prefer_value.to_i)
    end
    @achievements_with_info = []
    # uca = curr_user_course.user_achievements.includes(:achievement)
    # earned = uca.map(&:achievement)
    @achievements.each do |ach|
      req_check = {}
      if curr_user_course && ach.published
        uach = UserAchievement.find_by_user_course_id_and_achievement_id(
            curr_user_course.id, ach.id)
        ach.requirements.each do |req|
          req_check[req.id] = req.satisfied?(curr_user_course)
        end
        get_achievements_with_info ach, uach, req_check
      elsif can? :manage, Achievement
        get_achievements_with_info ach, false, req_check
      end
    end
  end

  def get_achievements_with_info(ach, uach, req_check)
    @achievements_with_info << {
        ach: ach,
        won: uach ? true : false,
        req_check: req_check
    }
  end

  def new
    @achievement.auto_assign = true
  end

  def edit
  end

  def show
    @uach = UserAchievement.find_by_user_course_id_and_achievement_id(
        curr_user_course.id, @achievement.id)
  end

  def create
    @achievement.creator = current_user
    @achievement.position = @course.achievements.count
    @achievement.update_requirement(params[:reqids], params[:new_reqs])

    @app_namespace = @graph.get_connection("app", "")["namespace"]
    facebook_obj_id = @graph.put_connections("app", "objects/#{@app_namespace}:badge", :object => JSON.generate(@badge))
    @achievement.facebook_obj_id = facebook_obj_id["id"]

    respond_to do |format|
      if @achievement.save

        format.html { redirect_to course_achievements_url(@course),
                                  notice: "The achievement '#{@achievement.title}' has been created." }
      else
        # delete badge if achievement cannot be saved
        @graph.graph_call("", {id: facebook_obj_id}, "delete")
        format.html { render action: "new" }
      end
    end
  end

  def update
    @achievement.update_requirement(params[:reqids], params[:new_reqs])
    respond_to do |format|
      if @achievement.update_attributes(params[:achievement])
        #update the Facebook object, catch the exception if the id doesn't exist
        init_badge
        begin
          @graph.graph_call("", {id: @achievement.facebook_obj_id, object: JSON.generate(@badge)}, "post")
        rescue Koala::Facebook::APIError => e
          logger.error e.fb_error_message
        end

        format.html { redirect_to course_achievements_url(@course),
                                  notice: "The achievement '#{@achievement.title}' has been updated." }
      else
        format.html { render action: "edit" }
      end
    end
  end

  def destroy
    # delete badge from Facebook, catch the exception if the id doesn't exist
    begin
      @graph.graph_call("", {id: @achievement.facebook_obj_id}, "delete")
    rescue Koala::Facebook::APIError => e
      logger.error e.fb_error_message
    end

    @achievement.destroy
    respond_to do |format|
      format.html { redirect_to course_achievements_url(@course),
                                notice: "The achievement '#{@achievement.title}' has been removed." }
    end
  end

  def reorder
    Achievement.reordering(params['sortable-item'])
    render nothing: true
  end

  private
    # initialize FB graph object with the app access token
    # graph will be used to manage (create update delete) badges
    def get_fbgraph_for_app
      oauth = Koala::Facebook::OAuth.new
      app_token = oauth.get_app_access_token

      @graph = Koala::Facebook::API.new(app_token)
    end

    # initialize the @badge instance variable with the necessary contents from @achievement
    def init_badge
      @badge = {"title" => @achievement.title, "description" => @achievement.description}

      #Facebook doesn't like an empty string for image URL
      unless @achievement.icon_url.blank?
        @badge["image"] = @achievement.icon_url
      end
    end
end
