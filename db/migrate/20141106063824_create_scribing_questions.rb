class CreateScribingQuestions < ActiveRecord::Migration
  def change
    create_table :assessment_scribing_questions do |t|

      t.timestamps
    end
  end
end
