class AssignmentRedesign < ActiveRecord::Migration
  def change
    create_table :assignments do |t|
      t.string      :type
      t.references  :course, index: true
      t.references  :creator
      t.references  :tab, index: true
      t.string      :title
      t.text        :description

      t.integer     :exp
      t.integer     :bonus_exp
      t.decimal     :max_grade

      t.boolean     :published
      t.boolean     :file_submission
      t.boolean     :single_question
      t.boolean     :file_submission_only
      t.boolean     :skippable

      t.datetime :open_at
      t.datetime :close_at
      t.datetime :bonus_cutoff_at
      t.datetime :deleted_at
      t.timestamps
    end

    create_table  :assignment_questions do |t|
      t.string      :type
      t.references  :assignment, index: true
      t.references  :creator
      t.references  :depends_on

      t.string      :title
      t.text        :description
      t.text        :data
      t.decimal     :max_grade
      t.integer     :pos
      t.boolean     :auto_graded

      t.datetime  :last_commented_at
      t.datetime  :deleted_at
      t.timestamps
    end

    create_table  :assignment_question_options do |t|
      t.references  :assignment, index: true
      t.references  :question, index: true
      t.text        :text
      t.text        :explanation
      t.boolean     :correct

      t.datetime  :deleted_at
      t.timestamps
    end

    create_table  :assignment_submissions do |t|
      t.references  :assignment, index: true
      t.references  :std_course, index: true
      t.string      :status,     index: true

      t.datetime    :open_at
      t.datetime    :submitted_at


      t.datetime  :deleted_at
      t.timestamps
    end

    create_table  :assignment_answers do |t|
      t.string      :type
      t.references  :assignment, index: true
      t.references  :submission, index: true
      t.references  :question,   index: true
      t.references  :std_course, index: true
      t.text        :answer, limit: 64.kilobytes + 1
      t.integer     :attempt_left
      t.boolean     :correct

      t.datetime  :deleted_at
      t.timestamps
    end

    change_table  :assignment_answers do |t|
      t.index [:assignment_id, :std_course_id]
    end

    create_table  :assignment_answer_options do |t|
      t.references  :answer
      t.references  :option
    end

    create_table  :assignment_gradings  do |t|
      t.references  :answer, index: true
      t.references  :grader_course
      t.decimal     :grade
      t.references  :exp_transaction

      t.datetime  :deleted_at
      t.timestamps
    end

    create_table  :taggable_tags do |t|
      t.string  :taggable_type
      t.integer :taggable_id, index: true
      t.references  :tag

      t.timestamps
    end

    change_table  :taggable_tags do |t|
      t.index [:taggable_id, :taggable_tags]
    end
  end
end
