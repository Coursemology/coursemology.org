class AssessmentsRedesign < ActiveRecord::Migration
  def change
    create_table :assessment_assessments, :as_relation_superclass => true do |t|
      t.references :course
      t.references :creator
      t.string :title
      t.text :description

      t.boolean :file_submission # was mission.is_file_submission
      t.boolean :publish
      t.integer :exp
      t.integer :max_grade

      t.datetime :open_at
      t.timestamps
      t.datetime :deleted_at
    end

    create_table :assessment_tags do |t|
      t.references :assessment
    end

    create_table :assessment_assessment_requirements do |t|

    end

    create_table :assessment_questions, :as_relation_superclass => true do |t|
      t.references :assessment, index: true
      t.references :creator
      t.text :description
      t.integer :max_grade
    end

    create_table :assessment_coding_questions do |t|
      t.string :title # was step_name

      t.text :staff_comment
      t.integer :depends_on # was include_sol_qn_id

      t.timestamps
    end

    create_table :assessment_mcq_questions do |t|
      t.boolean :must_select_all, :default => false # was select_all

      t.timestamps
    end

    create_table :assessment_mcq_options do |t| # was mcq_answers
      t.references :creator
      t.references :question, index: true # was mcq_id
      t.text :text
      t.text :explanation
      t.boolean :correct # was is_correct

      t.timestamps
    end

    create_table :assessment_submissions do |t|
      # Instead of finalising a submission, we finalise question by question.
      # This allows trainings to be finalised step-by-step.
      # To finalise the entire mission submission, for example, set all questions as finalised.
      t.references :assessment, index: true # was mission_id/training_id
      t.references :std_course, index: true
      t.string :status
      t.float :multiplier
      t.datetime :opened_at # was open_at
      t.datetime :submitted_at # was submit_at

      t.timestamps
      t.datetime :deleted_at

      # Number of attempts is computed by the number of gradings.
    end

    change_table :assessment_submissions do |t|
      t.index [:status]
    end

    create_table :assessment_question_submissions do |t|
      t.references :submission, index: true
      t.references :question, index: true
      t.boolean :finalised

      t.timestamps
    end

    create_table :assessment_coding_submissions do |t|
      t.text :code

      t.timestamps
    end

    create_table :assessment_mcq_submissions do |t|
      t.references :option

      t.timestamps
    end

    create_table :assessment_text_submissions do |t|
      t.text :text

      t.timestamps
    end

    create_table :assessment_gradings do |t|
      t.references :question_submission, index: true
      t.references :grader
      t.references :grader_course # curr_user_course for the grader
      t.integer :grade
      t.text :comment
      t.references :exp_transaction

      t.timestamps
    end

    create_table :assessment_trainings do |t|
      t.references :assessment, index: true
      t.integer :pos

      t.integer :bonus_exp
      t.datetime :bonus_cutoff
    end

    create_table :assessment_missions do |t|
      t.references :assessment, index: true
      t.integer :pos

      t.references :dependent, index: true
      t.datetime :close_at
    end
  end
end
