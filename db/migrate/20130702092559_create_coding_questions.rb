class CreateCodingQuestions < ActiveRecord::Migration
  def change
    create_table :coding_questions do |t|
      t.integer   :creator_id
      t.string    :step_name
      t.string    :description
      t.text      :data
      t.integer   :max_grade

      t.timestamps
    end
  end
end
