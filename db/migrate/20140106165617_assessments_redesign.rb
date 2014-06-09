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

      t.datetime :open_at
      t.timestamps
      t.datetime :deleted_at
    end

    create_table :assessment_assessments_tags do |t|
      t.belongs_to :assessment, index: true
      t.belongs_to :tag, index: true
    end

    change_table :assessment_assessments_tags do |t|
      t.index [:tag_id]
      t.index [:assessment_id]
    end

    create_table :assessment_assessments_requirements do |t|
      t.belongs_to :assessment, index: true
      t.integer :min_grade

      t.timestamps
    end

    change_table :assessment_assessments_requirements do |t|
      t.index [:assessment_id]
    end

    create_table :assessment_questions, :as_relation_superclass => true do |t|
      t.references :assessment, index: true
      t.references :creator
      t.text :description
      t.integer :max_grade
      t.integer :pos

      t.timestamps
    end

    change_table :assessment_questions do |t|
      t.index [:assessment_id]
    end

    create_table :assessment_coding_questions do |t|
      t.string :title # was step_name
      t.string :language # used to be in data, as JSON
      t.integer :time_limit # used to be in data, as JSON. This is in Seconds
      t.integer :memory_limit #used to be in data, as JSON. This is in MB
      t.integer :test_limit # used to be in data, as JSON. Number of tries.
      t.boolean :auto_graded
      t.text :data

      t.references :depends_on # was include_sol_qn_id
    end

    change_table :assessment_coding_questions do |t|
      t.index [:depends_on_id]
    end

    create_table :assessment_mcq_questions do |t|
      t.boolean :must_select_all, :default => false # was select_all
    end

    create_table :assessment_mcq_options do |t| # was mcq_answers
      t.references :creator
      t.references :question, index: true # was mcq_id
      t.text :text
      t.text :explanation
      t.boolean :correct # was is_correct

      t.timestamps
    end

    change_table :assessment_mcq_options do |t|
      t.index [:question_id]
    end

    create_table :assessment_text_questions do |t|
      # For future expansion
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
      t.index [:assessment_id]
      t.index [:std_course_id]
      t.index [:status]
    end

    create_table :assessment_answers, :as_relation_superclass => true do |t|
      t.references :submission, index: true
      t.references :question, index: true
      t.boolean :finalised

      t.timestamps
    end

    change_table :assessment_answers do |t|
      t.index [:submission_id]
      t.index [:question_id]
    end

    create_table :assessment_coding_answers do |t|
      t.text :code
    end

    create_table :assessment_mcq_answers do |t|
      # This just groups one set of options together to link a grade to.
    end

    create_table :assessment_mcq_answer_options do |t|
      t.references :answer
      t.references :option
    end

    change_table :assessment_mcq_answer_options do |t|
      t.index [:answer_id]
      t.index [:option_id]
    end

    create_table :assessment_text_answers do |t|
      t.text :text
    end

    create_table :assessment_gradings do |t|
      t.references :answer, index: true
      t.references :grader
      t.references :grader_course # curr_user_course for the grader
      t.integer :grade
      t.references :exp_transaction

      t.timestamps
    end

    change_table :assessment_gradings do |t|
      t.index [:answer_id]
    end

    create_table :assessment_trainings do |t|
      t.integer :pos

      t.integer :bonus_exp
      t.datetime :bonus_cutoff
    end

    create_table :assessment_missions do |t|
      t.integer :pos

      t.references :dependent, index: true
      t.datetime :close_at
    end

    change_table :assessment_missions do |t|
      t.index [:dependent_id]
    end
  end
end
