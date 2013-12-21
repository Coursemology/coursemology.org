class ChangePublishToCourse < ActiveRecord::Migration
  def change
    change_column :courses, :is_publish, :boolean, default: false
  end

end
