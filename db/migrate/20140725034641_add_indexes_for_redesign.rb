class AddIndexesForRedesign < ActiveRecord::Migration
  def up
    change_table  :assessments do |t|
      t.index [:as_assessment_id, :as_assessment_type], unique: true, name: :index_on_as_assessment
    end

    change_table  :assessment_questions do |t|
      t.index [:as_question_id, :as_question_type], unique: true, name: :index_on_as_question
    end

    change_table  :question_assessments do |t|
      t.index [:question_id, :assessment_id], name: :index_on_question_assessment
    end

    change_table  :assessment_answers do |t|
      t.index [:as_answer_id, :as_answer_type], unique: true, name: :index_on_as_answer
      t.index [:submission_id, :question_id], name: :index_on_answer_submission_question
      t.index :question_id
    end

    change_table :assessment_answer_gradings do |t|
      t.index [:answer_id, :grading_id]
    end

    change_table  :taggable_tags do |t|
      t.index [:taggable_id, :taggable_type]
    end

    change_table :requirable_requirements do |t|
      t.index [:requirable_id, :requirable_type], name: :index_on_requirables
    end

    change_table :assessment_answer_options do |t|
      t.index :answer_id
      t.index :option_id
    end
  end

  def down
  end
end
