class ChangeScribbleContentType < ActiveRecord::Migration
  def change
  	change_column :scribbles, :content, :text, limit: 16.megabytes - 1
  end
end
