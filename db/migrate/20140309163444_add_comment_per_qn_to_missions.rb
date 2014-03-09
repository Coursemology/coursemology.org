class AddCommentPerQnToMissions < ActiveRecord::Migration
  def change
    add_column :missions, :comment_per_qn, :boolean, default: true
  end
end
