# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121213172612) do

  create_table "announcements", :force => true do |t|
    t.integer  "creator_id"
    t.integer  "course_id"
    t.datetime "publish_at"
    t.integer  "important"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "title"
    t.string   "description"
  end

  create_table "answer_gradings", :force => true do |t|
    t.integer  "grader_id"
    t.integer  "grade"
    t.string   "comment"
    t.integer  "student_answer_id"
    t.integer  "submission_grading_id"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.string   "student_answer_type"
  end

  create_table "asm_qns", :force => true do |t|
    t.integer  "asm_id"
    t.string   "asm_type"
    t.integer  "qn_id"
    t.string   "qn_type"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "order"
  end

  create_table "assignments", :force => true do |t|
    t.integer  "course_id"
    t.integer  "exp"
    t.datetime "open_at"
    t.datetime "close_at"
    t.datetime "deadline"
    t.integer  "timelimit"
    t.integer  "attempt_limit"
    t.integer  "auto_graded"
    t.integer  "order"
    t.string   "description"
    t.integer  "creator_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "title"
    t.integer  "max_grade"
  end

  create_table "courses", :force => true do |t|
    t.string   "title"
    t.integer  "creator_id"
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "logo_url"
    t.string   "banner_url"
  end

  create_table "enroll_requests", :force => true do |t|
    t.integer  "user_id"
    t.integer  "course_id"
    t.integer  "role_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "mcq_answers", :force => true do |t|
    t.integer  "mcq_id"
    t.string   "text"
    t.integer  "creator_id"
    t.string   "explanation"
    t.boolean  "is_correct"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "mcqs", :force => true do |t|
    t.integer  "creator_id"
    t.string   "description"
    t.integer  "correct_answer_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "max_grade"
  end

  create_table "questions", :force => true do |t|
    t.integer  "creator_id"
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "max_grade"
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.string   "title"
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "sbm_answers", :force => true do |t|
    t.integer  "sbm_id"
    t.string   "sbm_type"
    t.integer  "answer_id"
    t.string   "answer_type"
    t.boolean  "is_final"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "std_answers", :force => true do |t|
    t.string   "text"
    t.integer  "student_id"
    t.integer  "question_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "std_mcq_answers", :force => true do |t|
    t.integer  "mcq_answer_id"
    t.string   "choices"
    t.integer  "student_id"
    t.integer  "mcq_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "student_answers", :force => true do |t|
    t.integer  "answer_id"
    t.datetime "started_at"
    t.datetime "submitted_at"
    t.string   "note"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "student_id"
    t.string   "text"
    t.integer  "answerable_id"
    t.string   "answerable_type"
    t.integer  "submission_id"
  end

  create_table "submission_gradings", :force => true do |t|
    t.integer  "grader_id"
    t.integer  "total_grade"
    t.string   "comment"
    t.integer  "submission_id"
    t.datetime "publish_at"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "submissions", :force => true do |t|
    t.integer  "student_id"
    t.integer  "assignment_id"
    t.datetime "open_at"
    t.datetime "submit_at"
    t.integer  "attempt"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "final_grading_id"
  end

  create_table "training_submissions", :force => true do |t|
    t.integer  "student_id"
    t.integer  "training_id"
    t.integer  "current_step"
    t.datetime "open_at"
    t.datetime "submit_at"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "trainings", :force => true do |t|
    t.integer  "course_id"
    t.integer  "creator_id"
    t.string   "title"
    t.string   "description"
    t.integer  "exp"
    t.datetime "open_at"
    t.integer  "order"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "max_grade"
  end

  create_table "user_courses", :force => true do |t|
    t.integer  "user_id"
    t.integer  "course_id"
    t.integer  "exp"
    t.integer  "role_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "profile_photo_url"
    t.string   "display_name"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "system_role_id"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
