class AddMaxGradeToTraining < ActiveRecord::Migration
  def change
    add_column :trainings, :max_grade, :integer
  end
end
