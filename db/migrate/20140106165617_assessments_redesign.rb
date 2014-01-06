class AssessmentsRedesign < ActiveRecord::Migration
  def change
    create_table :assessment_assessments do |t|
      t.string :type
    end

    create_table :assessment_tags do |t|
      t.integer :assessment_id
    end

    create_table :assessment_assessment_requirements do |t|

    end

    create_table :assessment_questions do |t|
      t.integer :assessment_id
      t.integer :max_grade
      t.string :type
    end

    create_table :assessment_coding_questions do |t|
      t.integer :creator_id
      t.string :title # was step_name
      t.text :description
      t.text :staff_comment
      t.integer :depends_on # was include_sol_qn_id

      t.timestamps
    end

    create_table :assessment_mcq_questions do |t|
      t.integer :creator_id
      t.text :description
      t.boolean :must_select_all, :default => false # was select_all
      t.integer :max_grade

      t.timestamps
    end

    create_table :assessment_mcq_options do |t| # was mcq_answers
      t.integer :creator_id
      t.integer :question_id # was mcq_id
      t.text :text
      t.text :explanation
      t.boolean :correct # was is_correct

      t.timestamps
    end

    create_table :assessment_text_questions do |t|
      t.integer :creator_id
      t.text :description
      t.integer :max_grade

      t.timestamps
    end

    create_table :assessment_submissions do |t|
      # Instead of finalising a submission, we finalise question by question.
      # This allows trainings to be finalised step-by-step.
      # To finalise the entire mission submission, for example, set all questions as finalised.
      t.integer :assessment_id # was mission_id/training_id
      t.integer :std_course_id
      t.string :status
      t.float :multiplier
      t.datetime :opened_at # was open_at
      t.datetime :submitted_at # was submit_at

      t.timestamps
      t.datetime :deleted_at

      # Number of attempts is computed by the number of gradings.
    end

    create_table :assessment_question_submissions do |t|
      t.integer :submission_id
      t.integer :question_id
      t.boolean :finalised

      t.timestamps
    end

    create_table :assessment_coding_submissions do |t|
      t.integer :question_submission_id
      t.text :code

      t.timestamps
    end

    create_table :assessment_mcq_submissions do |t|
      t.integer :question_submission_id
      t.integer :option_id

      t.timestamps
    end

    create_table :assessment_text_submissions do |t|
      t.integer :question_submission_id
      t.text :text

      t.timestamps
    end

    create_table :assessment_gradings do |t|
      t.integer :question_submission_id
      t.integer :grader
      t.integer :grade
      t.text :comment
      t.integer :exp_transaction_id
      t.integer :grader_course_id # curr_user_course for the grader

      t.timestamps
    end
  end
end
