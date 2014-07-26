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
      t.float       :max_grade
      t.boolean     :published
      t.boolean     :comment_per_qn, default: true
      t.references  :dependent, index: true
      t.references  :display_mode
      t.integer     :bonus_exp

      t.datetime    :bonus_cutoff_at
      t.datetime    :open_at
      t.datetime    :close_at
      t.datetime    :deleted_at
      t.timestamps
    end

    create_table  :assessment_missions do |t|
      t.boolean     :file_submission, default: false
      t.boolean     :file_submission_only, default: false

      t.datetime    :deleted_at
      t.timestamps
    end

    create_table  :assessment_trainings do |t|
      t.boolean     :skippable

      t.datetime    :deleted_at
      t.timestamps
    end


    create_table  :assessment_questions do |t|
      #for MTI
      t.integer     :as_question_id
      t.string      :as_question_type

      t.references  :creator
      t.references  :dependent, index: true
      t.string      :title
      t.text        :description
      t.float       :max_grade
      t.integer     :attempt_limit
      t.boolean     :file_submission, default: false
      t.text        :staff_comments

      t.datetime  :deleted_at
      t.timestamps
    end

    create_table  :assessment_coding_questions do |t|
      t.references  :language
      t.boolean     :auto_graded
      t.text        :tests
      t.integer     :memory_limit
      t.integer     :time_limit
      t.text        :template
      t.text        :pre_include
      t.text        :append_code

      t.datetime  :deleted_at
      t.timestamps
    end

    create_table  :programming_languages do |t|
      t.string  :name
      t.string  :codemirror_mode
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
      t.integer    :position

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
      t.datetime    :deleted_at
      t.timestamps
    end

    create_table  :assessment_answers do |t|
      t.integer     :as_answer_id
      t.string      :as_answer_type

      t.references  :submission, index: true
      t.references  :question,   index: true
      t.references  :std_course, index: true
      t.text        :content, limit: 64.kilobytes + 1
      t.integer     :attempt_left, default: 0
      t.boolean     :finalised, default: false
      t.boolean     :correct,   default: false

      t.datetime  :deleted_at
      t.timestamps
    end

    create_table :assessment_general_answers do |t|

      t.datetime  :deleted_at
      t.timestamps
    end

    create_table :assessment_mcq_answers do |t|

      t.datetime  :deleted_at
      t.timestamps
    end

    create_table :assessment_coding_answers do |t|
      t.text      :result

      t.datetime  :deleted_at
      t.timestamps
    end


    create_table  :assessment_answer_options do |t|
      t.references  :answer, index: true
      t.references  :option, index: true

      t.datetime  :deleted_at
      t.timestamps
    end

    create_table  :assessment_gradings  do |t|
      t.references  :submission, index: true
      t.references  :grader
      t.references  :grader_course
      t.references  :std_course, index: true
      t.float       :grade
      t.integer     :exp
      t.references  :exp_transaction
      t.boolean     :autograding_refresh, default: false

      t.datetime  :deleted_at
      t.timestamps
    end

    create_table  :assessment_answer_gradings do |t|
      t.references  :answer
      t.references  :grading, index: true
      t.references  :grader
      t.references  :grader_course, index: true
      t.float       :grade

      t.datetime  :deleted_at
      t.timestamps
    end

    create_table :assessment_grading_logs do |t|
      t.references  :grading, index: true
      t.references  :grader_course
      t.references  :grader
      t.float       :grade
      t.integer     :exp

      t.datetime  :deleted_at
      t.timestamps
    end

    create_table  :assessment_answer_grading_logs do |t|
      t.references  :answer_grading, index: true
      t.references  :grader_course
      t.references  :grader
      t.float     :grade

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

   create_table :requirable_requirements do |t|
     t.integer  :requirable_id
     t.string   :requirable_type
     t.references :requirement, index: true

     t.datetime  :deleted_at
     t.timestamps
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
    drop_table  :assessment_answer_options
    drop_table  :assessment_answer_gradings
    drop_table  :assessment_gradings
    drop_table  :assessment_grading_logs
    drop_table  :assessment_answer_grading_logs

    drop_table  :programming_languages
    drop_table  :taggable_tags
    drop_table  :requirable_requirements
    drop_table  :assessment_general_answers
    drop_table  :assessment_mcq_answers
    drop_table  :assessment_coding_answers

  end
end
