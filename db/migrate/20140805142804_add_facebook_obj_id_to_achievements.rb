class AddFacebookObjIdToAchievements < ActiveRecord::Migration
  def change
    add_column :achievements, :facebook_obj_id, :int8
  end
end
