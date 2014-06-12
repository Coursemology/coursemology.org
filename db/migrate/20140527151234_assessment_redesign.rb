class AssessmentRedesign < ActiveRecord::Migration
  def up
    create_table :assessments do |t|
      #for multiple table inheritance
      t.integer :as_assessment_id
      t.string  :as_assessment_type

      t.references  :course, index: true
      t.references  :creator
      t.references  :tab, index: true
      t.string      :title
      t.text        :description
      t.integer     :position
      t.integer     :exp
      t.decimal     :max_grade
      t.boolean     :published

      t.datetime    :open_at
      t.datetime    :deleted_at
      t.timestamps
    end

    create_table  :assessment_missions do |t|
      t.boolean     :file_submission, default: false
      t.boolean     :single_question, default: false
      t.boolean     :file_submission_only, default: false
      t.boolean     :comment_per_qn, default: true
      t.references  :dependent, index: true
      t.references  :display_mode

      t.datetime    :close_at
      t.datetime    :deleted_at
      t.timestamps
    end

    create_table  :assessment_trainings do |t|
      t.integer     :bonus_exp
      t.boolean     :skippable

      t.datetime    :bonus_cutoff_at
      t.datetime    :deleted_at
      t.timestamps
    end


    create_table  :assessment_questions do |t|
      #for MTI
      t.integer     :as_question_id
      t.string      :as_question_type

      t.references  :creator
      t.string      :title
      t.text        :description
      t.decimal     :max_grade
      t.integer     :position

      t.datetime  :last_commented_at
      t.datetime  :deleted_at
      t.timestamps
    end

    create_table  :assessment_coding_questions do |t|
      t.references  :dependent
      t.references  :language
      t.integer     :time_limit
      t.integer     :memory_limit
      t.integer     :test_limit
      t.boolean     :auto_graded
      t.text        :data

      t.datetime  :deleted_at
      t.timestamps
    end

    create_table  :programming_languages do |t|
      t.string  :language
      t.string  :version

      t.timestamps
    end

    create_table  :assessment_general_questions do |t|

      t.datetime  :deleted_at
      t.timestamps
    end

    create_table  :question_assessments do |t|
      t.references :question,   index: true
      t.references :assessment, index: true

      t.datetime  :deleted_at
      t.timestamps
    end

    create_table  :assessment_mcq_questions do |t|
      t.boolean :select_all, default: false
      t.datetime  :deleted_at

      t.timestamps
    end

    create_table  :assessment_mcq_options do |t|
      t.references  :creator
      t.references  :question, index: true
      t.text        :text
      t.text        :explanation
      t.boolean     :correct

      t.datetime  :deleted_at
      t.timestamps
    end

    create_table  :assessment_submissions do |t|
      t.references  :assessment, index: true
      t.references  :std_course, index: true
      t.string      :status,     index: true
      t.float       :multiplier

      t.datetime    :opened_at
      t.datetime    :submitted_at
      t.datetime  :deleted_at
      t.timestamps
    end

    create_table  :assessment_answers do |t|
      t.integer   :as_answer_id
      t.string    :as_answer_type

      t.references  :assessment, index: true
      t.references  :submission, index: true
      t.references  :question,   index: true
      t.references  :std_course, index: true
      t.text        :answer, limit: 64.kilobytes + 1
      t.boolean     :finalised, default: false

      t.datetime  :deleted_at
      t.timestamps
    end

    create_table :assessment_coding_answers do |t|
      t.integer     :attempt_left, default: 0
      t.boolean     :correct,   default: false

      t.datetime  :deleted_at
      t.timestamps
    end


    change_table  :assessment_answers do |t|
      t.index [:assessment_id, :std_course_id]
    end

    create_table  :assessment_answer_options do |t|
      t.references  :answer, index: true
      t.references  :option, index: true

      t.datetime  :deleted_at
      t.timestamps
    end

    create_table  :assessment_gradings  do |t|
      t.references  :submission
      t.references  :grader_course
      t.decimal     :grade
      t.references  :exp_transaction
      t.boolean     :autograding_refresh, default: false

      t.datetime  :deleted_at
      t.timestamps
    end

    create_table  :assessment_answer_gradings do |t|
      t.references  :answer
      t.references  :grading, index: true
      t.references  :grader_course, index: true
      t.decimal     :grade

      t.datetime  :deleted_at
      t.timestamps
    end

    create_table :assessment_grading_logs do |t|
      t.references  :grading, index: true
      t.references  :grader_course
      t.decimal     :grade

      t.datetime  :deleted_at
      t.timestamps
    end

    create_table  :assessment_answer_grading_logs do |t|
      t.references  :answer_grading, index: true
      t.references  :grader_course
      t.decimal     :grade

      t.datetime  :deleted_at
      t.timestamps
    end


    create_table  :taggable_tags do |t|
      t.string  :taggable_type
      t.integer :taggable_id
      t.references  :tag,     index: true

      t.datetime  :deleted_at
      t.timestamps
    end

    change_table  :taggable_tags do |t|
      t.index [:taggable_id, :taggable_type]
    end

   create_table :requirable_requirements do |t|
     t.integer  :requirable_id
     t.string   :requirable_type
     t.references :requirement, index: true

     t.datetime  :deleted_at
     t.timestamps
   end

    change_table :requirable_requirements do |t|
      t.index [:requirable_id, :requirable_type], name: :index_on_requirables
    end
  end

  def down
    drop_table  :assessments
    drop_table  :assessment_missions
    drop_table  :assessment_trainings
    drop_table  :assessment_questions
    drop_table  :assessment_coding_questions
    drop_table  :assessment_general_questions
    drop_table  :question_assessments
    drop_table  :assessment_mcq_questions
    drop_table  :assessment_mcq_options
    drop_table  :assessment_submissions
    drop_table  :assessment_answers
    drop_table  :assessment_coding_answers
    drop_table  :assessment_answer_options
    drop_table  :assessment_answer_gradings
    drop_table  :assessment_gradings
    drop_table  :assessment_grading_logs
    drop_table  :assessment_answer_grading_logs

    drop_table  :programming_languages
    drop_table  :taggable_tags
    drop_table  :requirable_requirements

  end
end
