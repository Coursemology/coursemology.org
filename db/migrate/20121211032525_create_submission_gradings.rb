class CreateSubmissionGradings < ActiveRecord::Migration
  def change
    create_table :submission_gradings do |t|
      t.integer :grader_id
      t.integer :total_grade
      t.string :comment
      t.integer :submission_id
      t.datetime :publish_at

      t.timestamps
    end
  end
end
