class ChangeDescriptionToText < ActiveRecord::Migration
  def change
    change_column :announcements, :description, :text
  end
end
