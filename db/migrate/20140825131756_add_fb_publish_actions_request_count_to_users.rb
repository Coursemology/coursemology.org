class AddFbPublishActionsRequestCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :fb_publish_actions_request_count,
                :tinyint, :null => false, :default => 0
  end
end
