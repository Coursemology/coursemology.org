class AddDefaultValueToIsContest < ActiveRecord::Migration
  def change
    change_column :surveys, :is_contest, :boolean, :default => false
  end
end
