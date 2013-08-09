class ChangeDateFormatInMcq < ActiveRecord::Migration
  def up
    change_column :mcqs, :last_commented_at, :datetime
  end

  def down
    change_column :mcqs, :last_commented_at, :time
  end
end
