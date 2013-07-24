class DropQuizSubmissions < ActiveRecord::Migration
  def up
    drop_table :quiz_submissions
  end

  def down
  end
end
