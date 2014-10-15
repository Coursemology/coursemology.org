namespace :db do
  require 'koala'
  require 'json'

  task add_achievements_to_fb: :environment do
    # setup the FB graph
    get_fbgraph_for_app
    app_info = @graph.get_connection("app", "")
    app_namespace = app_info["namespace"]

    #iterate through all undeleted achievements
    Achievement.all.each do |ach|
      # assume that if facebook_obj_id is not NULL, the Facebook object already exists
      # verifying the object ID with Facebook and trying to self correct is unnecessarily complicated for
      # a one time task
      if ach.facebook_obj_id.nil?
        badge = init_badge(ach) #prepare the badge object

        #post badge object to FB
        id = @graph.put_connections("app", "objects/#{app_namespace}:badge",
                                    :object => JSON.generate(badge))

        # get ID as response and save it to the db
        ach.facebook_obj_id = id["id"]
        ach.save!
        puts "Facebook object " + ach.facebook_obj_id.to_s + " created for " + ach.title
      end
    end
  end

  # same as functions in achievement controller
  def get_fbgraph_for_app
    oauth = Koala::Facebook::OAuth.new
    app_token = oauth.get_app_access_token
    @graph = Koala::Facebook::API.new(app_token)
  end

  def init_badge(ach)
    badge = {"title" => ach.title, "description" => ach.description}

    unless ach.icon_url.blank?
      badge["image"] = ach.icon_url
    end
    badge
  end
end
