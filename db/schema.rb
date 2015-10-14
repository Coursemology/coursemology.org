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

ActiveRecord::Schema.define(:version => 20151014153816) do

  create_table "achievements", :force => true do |t|
    t.string   "icon_url"
    t.string   "title"
    t.text     "description"
    t.integer  "creator_id"
    t.integer  "course_id"
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
    t.time     "deleted_at"
    t.boolean  "auto_assign"
    t.text     "requirement_text"
    t.boolean  "published",                     :default => true
    t.integer  "facebook_obj_id",  :limit => 8
    t.integer  "position"
  end

  add_index "achievements", ["course_id"], :name => "index_achievements_on_course_id"
  add_index "achievements", ["creator_id"], :name => "index_achievements_on_creator_id"

  create_table "actions", :force => true do |t|
    t.string   "text"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "actions", ["text"], :name => "index_actions_on_text"

  create_table "activities", :force => true do |t|
    t.integer  "course_id"
    t.integer  "actor_course_id"
    t.integer  "target_course_id"
    t.integer  "action_id"
    t.integer  "obj_id"
    t.string   "obj_type"
    t.string   "extra"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "obj_url"
  end

  add_index "activities", ["action_id"], :name => "index_activities_on_action_id"
  add_index "activities", ["actor_course_id"], :name => "index_activities_on_actor_course_id"
  add_index "activities", ["course_id"], :name => "index_activities_on_course_id"
  add_index "activities", ["created_at"], :name => "index_activities_on_created_at"
  add_index "activities", ["obj_id", "obj_type"], :name => "index_activities_on_obj_id_and_obj_type"
  add_index "activities", ["target_course_id"], :name => "index_activities_on_target_course_id"

  create_table "annotations", :force => true do |t|
    t.integer  "annotable_id"
    t.string   "annotable_type"
    t.integer  "line_start"
    t.integer  "line_end"
    t.integer  "user_course_id"
    t.text     "text"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.time     "deleted_at"
  end

  add_index "annotations", ["annotable_id"], :name => "index_annotations_on_annotable_id"
  add_index "annotations", ["annotable_type"], :name => "index_annotations_on_annotable_type"
  add_index "annotations", ["user_course_id"], :name => "index_annotations_on_user_course_id"

  create_table "announcements", :force => true do |t|
    t.integer  "creator_id"
    t.integer  "course_id"
    t.datetime "publish_at"
    t.integer  "important"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "title"
    t.text     "description"
    t.time     "deleted_at"
    t.datetime "expiry_at"
  end

  add_index "announcements", ["course_id"], :name => "index_announcements_on_course_id"
  add_index "announcements", ["creator_id"], :name => "index_announcements_on_creator_id"

  create_table "answer_gradings", :force => true do |t|
    t.integer  "grader_id"
    t.integer  "grade"
    t.text     "comment"
    t.integer  "student_answer_id"
    t.integer  "submission_grading_id"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.string   "student_answer_type"
    t.integer  "exp"
  end

  add_index "answer_gradings", ["grader_id"], :name => "index_answer_gradings_on_grader_id"
  add_index "answer_gradings", ["student_answer_id"], :name => "index_answer_gradings_on_student_answer_id"
  add_index "answer_gradings", ["submission_grading_id"], :name => "index_answer_gradings_on_submission_grading_id"

  create_table "asm_qns", :force => true do |t|
    t.integer  "asm_id"
    t.string   "asm_type"
    t.integer  "qn_id"
    t.string   "qn_type"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "pos"
  end

  add_index "asm_qns", ["asm_id"], :name => "index_asm_qns_on_asm_id"
  add_index "asm_qns", ["asm_type"], :name => "index_asm_qns_on_asm_type"
  add_index "asm_qns", ["qn_id"], :name => "index_asm_qns_on_qn_id"

  create_table "asm_reqs", :force => true do |t|
    t.integer  "asm_id"
    t.string   "asm_type"
    t.integer  "min_grade"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "asm_reqs", ["asm_id"], :name => "index_asm_reqs_on_asm_id"
  add_index "asm_reqs", ["asm_type"], :name => "index_asm_reqs_on_asm_type"

  create_table "asm_tags", :force => true do |t|
    t.integer  "asm_id"
    t.string   "asm_type"
    t.integer  "tag_id"
    t.integer  "max_exp"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "asm_tags", ["asm_id"], :name => "index_asm_tags_on_asm_id"
  add_index "asm_tags", ["tag_id"], :name => "index_asm_tags_on_tag_id"

  create_table "assessment_answer_grading_logs", :force => true do |t|
    t.integer  "answer_grading_id"
    t.integer  "grader_course_id"
    t.integer  "grader_id"
    t.float    "grade"
    t.datetime "deleted_at"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "assessment_answer_gradings", :force => true do |t|
    t.integer  "answer_id"
    t.integer  "grading_id"
    t.integer  "grader_id"
    t.integer  "grader_course_id"
    t.float    "grade"
    t.datetime "deleted_at"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "assessment_answer_gradings", ["answer_id", "grading_id"], :name => "index_assessment_answer_gradings_on_answer_id_and_grading_id"

  create_table "assessment_answer_options", :force => true do |t|
    t.integer  "answer_id"
    t.integer  "option_id"
    t.datetime "deleted_at"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "assessment_answer_options", ["answer_id"], :name => "index_assessment_answer_options_on_answer_id"
  add_index "assessment_answer_options", ["option_id"], :name => "index_assessment_answer_options_on_option_id"

  create_table "assessment_answers", :force => true do |t|
    t.integer  "as_answer_id"
    t.string   "as_answer_type"
    t.integer  "submission_id"
    t.integer  "question_id"
    t.integer  "std_course_id"
    t.text     "content",        :limit => 16777215
    t.integer  "attempt_left",                       :default => 0
    t.boolean  "finalised",                          :default => false
    t.boolean  "correct",                            :default => false
    t.datetime "deleted_at"
    t.datetime "created_at",                                            :null => false
    t.datetime "updated_at",                                            :null => false
  end

  add_index "assessment_answers", ["as_answer_id", "as_answer_type"], :name => "index_on_as_answer", :unique => true
  add_index "assessment_answers", ["question_id"], :name => "index_assessment_answers_on_question_id"
  add_index "assessment_answers", ["submission_id", "question_id"], :name => "index_on_answer_submission_question"

  create_table "assessment_auto_grading_exact_options", :force => true do |t|
    t.integer "general_question_id"
    t.boolean "correct"
    t.text    "answer"
    t.text    "explanation"
  end

  create_table "assessment_auto_grading_keyword_options", :force => true do |t|
    t.integer "general_question_id"
    t.string  "keyword"
    t.integer "score"
  end

  create_table "assessment_coding_answers", :force => true do |t|
    t.text     "result"
    t.datetime "deleted_at"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "assessment_coding_questions", :force => true do |t|
    t.integer  "language_id"
    t.boolean  "auto_graded"
    t.text     "tests"
    t.integer  "memory_limit"
    t.integer  "time_limit"
    t.text     "template"
    t.text     "pre_include"
    t.text     "append_code"
    t.datetime "deleted_at"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "assessment_dependency", :id => false, :force => true do |t|
    t.integer "id",           :default => 0, :null => false
    t.integer "dependent_id"
  end

  create_table "assessment_general_answers", :force => true do |t|
    t.datetime "deleted_at"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "assessment_general_questions", :force => true do |t|
    t.datetime "deleted_at"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.boolean  "auto_graded"
    t.integer  "auto_grading_type_cd", :default => 0
    t.text     "sample_answer"
  end

  create_table "assessment_grading_logs", :force => true do |t|
    t.integer  "grading_id"
    t.integer  "grader_course_id"
    t.integer  "grader_id"
    t.float    "grade"
    t.integer  "exp"
    t.datetime "deleted_at"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "assessment_gradings", :force => true do |t|
    t.integer  "submission_id"
    t.integer  "grader_id"
    t.integer  "grader_course_id"
    t.integer  "std_course_id"
    t.float    "grade"
    t.integer  "exp"
    t.integer  "exp_transaction_id"
    t.boolean  "autograding_refresh", :default => false
    t.datetime "deleted_at"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "assessment_gradings", ["submission_id"], :name => "index_assessment_gradings_on_submission_id", :unique => true

  create_table "assessment_mcq_answers", :force => true do |t|
    t.datetime "deleted_at"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "assessment_mcq_options", :force => true do |t|
    t.integer  "creator_id"
    t.integer  "question_id"
    t.text     "text"
    t.text     "explanation"
    t.boolean  "correct"
    t.datetime "deleted_at"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "assessment_mcq_questions", :force => true do |t|
    t.boolean  "select_all", :default => false
    t.datetime "deleted_at"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "assessment_missions", :force => true do |t|
    t.boolean  "file_submission",      :default => false
    t.boolean  "file_submission_only", :default => false
    t.datetime "deleted_at"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
  end

  create_table "assessment_questions", :force => true do |t|
    t.integer  "as_question_id"
    t.string   "as_question_type"
    t.integer  "creator_id"
    t.integer  "dependent_id"
    t.string   "title"
    t.text     "description"
    t.float    "max_grade"
    t.integer  "attempt_limit"
    t.boolean  "file_submission",  :default => false
    t.text     "staff_comments"
    t.datetime "deleted_at"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
  end

  add_index "assessment_questions", ["as_question_id", "as_question_type"], :name => "index_on_as_question", :unique => true

  create_table "assessment_scribing_answers", :force => true do |t|
    t.datetime "deleted_at"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "assessment_scribing_questions", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.datetime "deleted_at"
  end

  create_table "assessment_submissions", :force => true do |t|
    t.integer  "assessment_id"
    t.integer  "std_course_id"
    t.string   "status"
    t.float    "multiplier"
    t.datetime "opened_at"
    t.datetime "submitted_at"
    t.datetime "deleted_at"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.datetime "saved_at"
  end

  add_index "assessment_submissions", ["assessment_id", "std_course_id"], :name => "index_assessment_submissions_on_assessment_id_and_std_course_id", :unique => true

  create_table "assessment_trainings", :force => true do |t|
    t.boolean  "skippable"
    t.datetime "deleted_at"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "assessments", :force => true do |t|
    t.integer  "as_assessment_id",                     :null => false
    t.string   "as_assessment_type",                   :null => false
    t.integer  "course_id"
    t.integer  "creator_id"
    t.integer  "tab_id"
    t.string   "title"
    t.text     "description"
    t.integer  "position"
    t.integer  "exp"
    t.float    "max_grade"
    t.boolean  "published"
    t.boolean  "comment_per_qn",     :default => true
    t.integer  "display_mode_id"
    t.integer  "bonus_exp"
    t.datetime "bonus_cutoff_at"
    t.datetime "open_at"
    t.datetime "close_at"
    t.datetime "deleted_at"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
  end

  add_index "assessments", ["as_assessment_id", "as_assessment_type"], :name => "index_on_as_assessment", :unique => true

  create_table "assignment_display_modes", :force => true do |t|
    t.string "title"
    t.string "description"
  end

  create_table "assignment_types", :force => true do |t|
    t.string   "title"
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "coding_questions", :force => true do |t|
    t.integer  "creator_id"
    t.string   "step_name"
    t.text     "description"
    t.text     "data"
    t.integer  "max_grade"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.string   "staff_comments"
    t.datetime "last_commented_at"
    t.integer  "include_sol_qn_id"
    t.boolean  "is_auto_grading",   :default => false
  end

  create_table "comic_pages", :force => true do |t|
    t.integer  "comic_id"
    t.integer  "page"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.boolean  "is_tbc",     :default => false
  end

  add_index "comic_pages", ["comic_id"], :name => "index_comic_pages_on_comic_id"

  create_table "comics", :force => true do |t|
    t.string   "name"
    t.integer  "chapter"
    t.integer  "episode"
    t.boolean  "visible"
    t.integer  "course_id"
    t.integer  "dependent_mission_id"
    t.integer  "next_mission_id"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  add_index "comics", ["course_id"], :name => "index_comics_on_course_id"
  add_index "comics", ["dependent_mission_id"], :name => "index_comics_on_dependent_mission_id"
  add_index "comics", ["next_mission_id"], :name => "index_comics_on_next_mission_id"

  create_table "comment_subscriptions", :force => true do |t|
    t.integer  "topic_id"
    t.string   "topic_type"
    t.integer  "course_id"
    t.integer  "user_course_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "comment_topic_id"
  end

  add_index "comment_subscriptions", ["comment_topic_id"], :name => "index_comment_subscriptions_on_comment_topic_id"
  add_index "comment_subscriptions", ["course_id"], :name => "index_comment_subscriptions_on_course_id"
  add_index "comment_subscriptions", ["topic_id", "topic_type"], :name => "index_comment_subscriptions_on_topic_id_and_topic_type"
  add_index "comment_subscriptions", ["user_course_id"], :name => "index_comment_subscriptions_on_user_course_id"

  create_table "comment_topics", :force => true do |t|
    t.integer  "course_id"
    t.integer  "topic_id"
    t.string   "topic_type"
    t.datetime "last_commented_at"
    t.boolean  "pending"
    t.string   "permalink"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "comment_topics", ["course_id"], :name => "index_comment_topics_on_course_id"
  add_index "comment_topics", ["pending"], :name => "index_comment_topics_on_pending"
  add_index "comment_topics", ["topic_id", "topic_type"], :name => "index_comment_topics_on_topic_id_and_topic_type"

  create_table "comments", :force => true do |t|
    t.integer  "user_course_id"
    t.text     "text"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.time     "deleted_at"
    t.integer  "comment_topic_id"
  end

  add_index "comments", ["comment_topic_id"], :name => "index_comments_on_comment_topic_id"
  add_index "comments", ["commentable_id", "commentable_type"], :name => "index_comments_on_commentable_id_and_commentable_type"
  add_index "comments", ["commentable_id"], :name => "index_comments_on_commentable_id"
  add_index "comments", ["user_course_id"], :name => "index_comments_on_user_course_id"

  create_table "course_navbar_preferences", :force => true do |t|
    t.integer  "course_id"
    t.integer  "navbar_preferable_item_id"
    t.integer  "navbar_link_type_id"
    t.string   "item"
    t.string   "name"
    t.boolean  "is_displayed"
    t.boolean  "is_enabled"
    t.string   "description"
    t.string   "link_to"
    t.integer  "pos"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "course_navbar_preferences", ["course_id", "navbar_preferable_item_id"], :name => "index_cnp_on_course_id_and_navbar_preferable_item_id"
  add_index "course_navbar_preferences", ["course_id"], :name => "index_course_navbar_preferences_on_course_id"

  create_table "course_preferences", :force => true do |t|
    t.integer  "course_id"
    t.integer  "preferable_item_id"
    t.string   "prefer_value"
    t.boolean  "display"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "course_preferences", ["course_id", "preferable_item_id"], :name => "index_course_preferences_on_course_id_and_preferable_item_id", :unique => true
  add_index "course_preferences", ["course_id"], :name => "index_course_preferences_on_course_id"
  add_index "course_preferences", ["preferable_item_id"], :name => "index_course_preferences_on_preferable_item_id"

  create_table "course_theme_attributes", :force => true do |t|
    t.integer  "course_id"
    t.integer  "theme_attribute_id"
    t.string   "value"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "course_theme_attributes", ["course_id"], :name => "index_course_theme_attributes_on_course_id"
  add_index "course_theme_attributes", ["theme_attribute_id"], :name => "index_course_theme_attributes_on_theme_attribute_id"

  create_table "course_themes", :force => true do |t|
    t.integer  "course_id"
    t.integer  "theme_id"
    t.string   "theme_folder_url"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "course_themes", ["course_id"], :name => "index_course_themes_on_course_id"
  add_index "course_themes", ["theme_id"], :name => "index_course_themes_on_theme_id"

  create_table "courses", :force => true do |t|
    t.string   "title"
    t.integer  "creator_id"
    t.text     "description"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "logo_url"
    t.string   "banner_url"
    t.time     "deleted_at"
    t.boolean  "is_publish",          :default => false
    t.boolean  "is_open",             :default => true
    t.boolean  "is_active",           :default => true
    t.datetime "start_at"
    t.datetime "end_at"
    t.boolean  "is_pending_deletion", :default => false
  end

  add_index "courses", ["creator_id"], :name => "index_courses_on_creator_id"

  create_table "data_maps", :force => true do |t|
    t.string  "data_type"
    t.integer "old_data_id"
    t.integer "new_data_id"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "duplicate_logs", :force => true do |t|
    t.integer  "user_id"
    t.integer  "origin_course_id"
    t.integer  "dest_course_id"
    t.integer  "origin_obj_id"
    t.string   "origin_obj_type"
    t.integer  "dest_obj_id"
    t.string   "dest_obj_type"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "duplicate_logs", ["dest_course_id"], :name => "index_duplicate_logs_on_dest_course_id"
  add_index "duplicate_logs", ["dest_obj_id", "dest_obj_type"], :name => "index_duplicate_logs_on_dest_obj_id_and_dest_obj_type"
  add_index "duplicate_logs", ["origin_course_id"], :name => "index_duplicate_logs_on_origin_course_id"
  add_index "duplicate_logs", ["origin_obj_id", "origin_obj_type"], :name => "index_duplicate_logs_on_origin_obj_id_and_origin_obj_type"
  add_index "duplicate_logs", ["user_id"], :name => "index_duplicate_logs_on_user_id"

  create_table "enroll_requests", :force => true do |t|
    t.integer  "user_id"
    t.integer  "course_id"
    t.integer  "role_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.time     "deleted_at"
  end

  add_index "enroll_requests", ["course_id"], :name => "index_enroll_requests_on_course_id"
  add_index "enroll_requests", ["role_id"], :name => "index_enroll_requests_on_role_id"
  add_index "enroll_requests", ["user_id"], :name => "index_enroll_requests_on_user_id"

  create_table "exp_transactions", :force => true do |t|
    t.integer  "exp"
    t.string   "reason"
    t.boolean  "is_valid"
    t.integer  "user_course_id"
    t.integer  "giver_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.time     "deleted_at"
    t.integer  "rewardable_id"
    t.string   "rewardable_type"
  end

  add_index "exp_transactions", ["giver_id"], :name => "index_exp_transactions_on_giver_id"
  add_index "exp_transactions", ["rewardable_id", "rewardable_type"], :name => "index_exp_transactions_on_rewardable_id_and_rewardable_type"
  add_index "exp_transactions", ["user_course_id"], :name => "index_exp_transactions_on_user_course_id"

  create_table "file_uploads", :force => true do |t|
    t.integer  "owner_id"
    t.integer  "creator_id"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.string   "owner_type"
    t.string   "original_name"
    t.string   "copy_url"
    t.boolean  "is_public",         :default => true
  end

  add_index "file_uploads", ["creator_id"], :name => "index_file_uploads_on_creator_id"
  add_index "file_uploads", ["owner_id", "owner_type"], :name => "index_file_uploads_on_owner_id_and_owner_type"

  create_table "forem_categories", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "slug"
  end

  add_index "forem_categories", ["slug"], :name => "index_forem_categories_on_slug", :unique => true

  create_table "forem_category_subscriptions", :force => true do |t|
    t.integer "subscriber_id"
    t.integer "category_id"
    t.integer "is_digest",     :default => 0
  end

  create_table "forem_forums", :force => true do |t|
    t.string  "name"
    t.text    "description"
    t.integer "category_id"
    t.integer "views_count", :default => 0
    t.string  "slug"
  end

  add_index "forem_forums", ["slug"], :name => "index_forem_forums_on_slug", :unique => true

  create_table "forem_groups", :force => true do |t|
    t.string "name"
  end

  add_index "forem_groups", ["name"], :name => "index_forem_groups_on_name"

  create_table "forem_memberships", :force => true do |t|
    t.integer "group_id"
    t.integer "member_id"
  end

  add_index "forem_memberships", ["group_id"], :name => "index_forem_memberships_on_group_id"

  create_table "forem_moderator_groups", :force => true do |t|
    t.integer "forum_id"
    t.integer "group_id"
  end

  add_index "forem_moderator_groups", ["forum_id"], :name => "index_forem_moderator_groups_on_forum_id"

  create_table "forem_posts", :force => true do |t|
    t.integer  "topic_id"
    t.text     "text"
    t.integer  "user_id"
    t.datetime "created_at",                                       :null => false
    t.datetime "updated_at",                                       :null => false
    t.integer  "reply_to_id"
    t.string   "state",              :default => "pending_review"
    t.boolean  "notified",           :default => false
    t.integer  "cached_votes_total", :default => 0
    t.integer  "cached_votes_score", :default => 0
    t.integer  "cached_votes_up",    :default => 0
    t.integer  "cached_votes_down",  :default => 0
  end

  add_index "forem_posts", ["cached_votes_down"], :name => "index_forem_posts_on_cached_votes_down"
  add_index "forem_posts", ["cached_votes_score"], :name => "index_forem_posts_on_cached_votes_score"
  add_index "forem_posts", ["cached_votes_total"], :name => "index_forem_posts_on_cached_votes_total"
  add_index "forem_posts", ["cached_votes_up"], :name => "index_forem_posts_on_cached_votes_up"
  add_index "forem_posts", ["reply_to_id"], :name => "index_forem_posts_on_reply_to_id"
  add_index "forem_posts", ["state"], :name => "index_forem_posts_on_state"
  add_index "forem_posts", ["topic_id"], :name => "index_forem_posts_on_topic_id"
  add_index "forem_posts", ["user_id"], :name => "index_forem_posts_on_user_id"

  create_table "forem_subscriptions", :force => true do |t|
    t.integer "subscriber_id"
    t.integer "topic_id"
  end

  create_table "forem_topics", :force => true do |t|
    t.integer  "forum_id"
    t.integer  "user_id"
    t.string   "subject"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.boolean  "locked",       :default => false,            :null => false
    t.boolean  "pinned",       :default => false
    t.boolean  "hidden",       :default => false
    t.datetime "last_post_at"
    t.string   "state",        :default => "pending_review"
    t.integer  "views_count",  :default => 0
    t.string   "slug"
    t.integer  "notified",     :default => 0
  end

  add_index "forem_topics", ["forum_id"], :name => "index_forem_topics_on_forum_id"
  add_index "forem_topics", ["slug"], :name => "index_forem_topics_on_slug", :unique => true
  add_index "forem_topics", ["state"], :name => "index_forem_topics_on_state"
  add_index "forem_topics", ["user_id"], :name => "index_forem_topics_on_user_id"

  create_table "forem_views", :force => true do |t|
    t.integer  "user_id"
    t.integer  "viewable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "count",             :default => 0
    t.string   "viewable_type"
    t.datetime "current_viewed_at"
    t.datetime "past_viewed_at"
  end

  add_index "forem_views", ["updated_at"], :name => "index_forem_views_on_updated_at"
  add_index "forem_views", ["user_id"], :name => "index_forem_views_on_user_id"
  add_index "forem_views", ["viewable_id"], :name => "index_forem_views_on_topic_id"

  create_table "forum_forum_subscriptions", :force => true do |t|
    t.integer "forum_id"
    t.integer "user_id"
  end

  add_index "forum_forum_subscriptions", ["forum_id"], :name => "index_forum_forum_subscriptions_on_forum_id"
  add_index "forum_forum_subscriptions", ["user_id"], :name => "index_forum_forum_subscriptions_on_user_id"

  create_table "forum_forums", :force => true do |t|
    t.integer "course_id"
    t.string  "name"
    t.string  "cached_slug"
    t.text    "description"
    t.boolean "locked",      :default => false
  end

  add_index "forum_forums", ["cached_slug"], :name => "index_forum_forums_on_cached_slug", :unique => true
  add_index "forum_forums", ["course_id"], :name => "index_forum_forums_on_course_id"

  create_table "forum_post_votes", :force => true do |t|
    t.integer  "post_id"
    t.integer  "vote"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "forum_posts", :force => true do |t|
    t.integer  "topic_id"
    t.integer  "parent_id"
    t.string   "title"
    t.integer  "author_id"
    t.boolean  "answer"
    t.text     "text"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "forum_posts", ["author_id"], :name => "index_forum_posts_on_author_id"
  add_index "forum_posts", ["parent_id"], :name => "index_forum_posts_on_parent_id"
  add_index "forum_posts", ["topic_id"], :name => "index_forum_posts_on_topic_id"

  create_table "forum_topic_subscriptions", :force => true do |t|
    t.integer "topic_id"
    t.integer "user_id"
  end

  add_index "forum_topic_subscriptions", ["topic_id"], :name => "index_forum_topic_subscriptions_on_topic_id"
  add_index "forum_topic_subscriptions", ["user_id"], :name => "index_forum_topic_subscriptions_on_user_id"

  create_table "forum_topic_views", :force => true do |t|
    t.integer  "topic_id"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "forum_topic_views", ["topic_id"], :name => "index_forum_topic_views_on_topic_id"
  add_index "forum_topic_views", ["user_id"], :name => "index_forum_topic_views_on_user_id"

  create_table "forum_topics", :force => true do |t|
    t.integer  "forum_id"
    t.string   "title"
    t.string   "cached_slug"
    t.integer  "author_id"
    t.boolean  "locked",      :default => false
    t.boolean  "hidden",      :default => false
    t.integer  "topic_type",  :default => 0
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "forum_topics", ["author_id"], :name => "index_forum_topics_on_author_id"
  add_index "forum_topics", ["cached_slug"], :name => "index_forum_topics_on_cached_slug", :unique => true
  add_index "forum_topics", ["forum_id"], :name => "index_forum_topics_on_forum_id"

  create_table "guild_users", :force => true do |t|
    t.integer  "role_id"
    t.integer  "user_course_id"
    t.integer  "guild_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "guilds", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "course_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "lesson_plan_entries", :force => true do |t|
    t.integer  "course_id"
    t.integer  "creator_id"
    t.string   "title"
    t.integer  "entry_type"
    t.text     "description"
    t.datetime "start_at"
    t.datetime "end_at"
    t.string   "location"
  end

  add_index "lesson_plan_entries", ["course_id"], :name => "index_lesson_plan_entries_on_course_id"
  add_index "lesson_plan_entries", ["creator_id"], :name => "index_lesson_plan_entries_on_creator_id"

  create_table "lesson_plan_milestones", :force => true do |t|
    t.integer  "course_id"
    t.integer  "creator_id"
    t.string   "title"
    t.text     "description"
    t.datetime "end_at"
    t.datetime "start_at"
    t.boolean  "is_publish",  :default => true
  end

  add_index "lesson_plan_milestones", ["course_id"], :name => "index_lesson_plan_milestones_on_course_id"
  add_index "lesson_plan_milestones", ["creator_id"], :name => "index_lesson_plan_milestones_on_creator_id"

  create_table "lesson_plan_resources", :force => true do |t|
    t.integer "lesson_plan_entry_id"
    t.integer "obj_id"
    t.string  "obj_type"
  end

  add_index "lesson_plan_resources", ["lesson_plan_entry_id"], :name => "index_lesson_plan_resources_on_lesson_plan_entry_id"
  add_index "lesson_plan_resources", ["obj_id", "obj_type"], :name => "index_lesson_plan_resources_on_obj_id_and_obj_type"

  create_table "levels", :force => true do |t|
    t.integer  "level"
    t.integer  "exp_threshold"
    t.integer  "course_id"
    t.integer  "creator_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "levels", ["course_id"], :name => "index_levels_on_course_id"
  add_index "levels", ["creator_id"], :name => "index_levels_on_creator_id"

  create_table "masquerade_logs", :force => true do |t|
    t.integer  "by_user_id"
    t.integer  "as_user_id"
    t.text     "action"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "mass_enrollment_emails", :force => true do |t|
    t.integer  "course_id"
    t.string   "name"
    t.string   "email"
    t.boolean  "signed_up",      :default => false
    t.integer  "delayed_job_id"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.string   "confirm_token"
    t.boolean  "pending_email",  :default => true
  end

  add_index "mass_enrollment_emails", ["course_id"], :name => "index_mass_enrollment_emails_on_course_id"
  add_index "mass_enrollment_emails", ["delayed_job_id"], :name => "index_mass_enrollment_emails_on_delayed_job_id"

  create_table "material_folders", :force => true do |t|
    t.integer  "parent_folder_id"
    t.integer  "course_id"
    t.string   "name"
    t.text     "description"
    t.datetime "open_at"
    t.datetime "close_at"
    t.boolean  "can_student_upload", :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "material_folders", ["course_id"], :name => "index_material_folders_on_course_id"
  add_index "material_folders", ["parent_folder_id"], :name => "index_material_folders_on_parent_folder_id"

  create_table "materials", :force => true do |t|
    t.integer  "folder_id"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "materials", ["folder_id"], :name => "index_materials_on_folder_id"

  create_table "mcq_answers", :force => true do |t|
    t.integer  "mcq_id"
    t.text     "text"
    t.integer  "creator_id"
    t.text     "explanation"
    t.boolean  "is_correct"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "mcq_answers", ["creator_id"], :name => "index_mcq_answers_on_creator_id"
  add_index "mcq_answers", ["mcq_id"], :name => "index_mcq_answers_on_mcq_id"

  create_table "mcqs", :force => true do |t|
    t.integer  "creator_id"
    t.text     "description"
    t.integer  "correct_answer_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "max_grade"
    t.text     "correct_answers"
    t.boolean  "select_all"
    t.datetime "last_commented_at"
  end

  add_index "mcqs", ["correct_answer_id"], :name => "index_mcqs_on_correct_answer_id"
  add_index "mcqs", ["creator_id"], :name => "index_mcqs_on_creator_id"

  create_table "missions", :force => true do |t|
    t.integer  "course_id"
    t.integer  "exp"
    t.datetime "open_at"
    t.datetime "close_at"
    t.datetime "deadline"
    t.integer  "timelimit"
    t.integer  "attempt_limit"
    t.integer  "auto_graded"
    t.integer  "pos"
    t.text     "description"
    t.integer  "creator_id"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.string   "title"
    t.integer  "max_grade"
    t.boolean  "single_question",    :default => false
    t.boolean  "is_file_submission", :default => false
    t.integer  "dependent_id"
    t.boolean  "publish",            :default => true
    t.integer  "tab_id"
  end

  add_index "missions", ["course_id"], :name => "index_missions_on_course_id"
  add_index "missions", ["creator_id"], :name => "index_missions_on_creator_id"

  create_table "navbar_link_types", :force => true do |t|
    t.string   "link_type"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "navbar_preferable_items", :force => true do |t|
    t.string   "item"
    t.integer  "navbar_link_type_id"
    t.string   "name"
    t.boolean  "is_displayed"
    t.boolean  "is_enabled"
    t.string   "description"
    t.string   "link_to"
    t.integer  "pos"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "notifications", :force => true do |t|
    t.integer  "target_course_id"
    t.integer  "actor_course_id"
    t.integer  "action_id"
    t.integer  "obj_id"
    t.string   "obj_type"
    t.string   "extra"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "notifications", ["action_id"], :name => "index_notifications_on_action_id"
  add_index "notifications", ["actor_course_id"], :name => "index_notifications_on_actor_course_id"
  add_index "notifications", ["obj_id", "obj_type"], :name => "index_notifications_on_obj_id_and_obj_type"
  add_index "notifications", ["target_course_id"], :name => "index_notifications_on_target_course_id"

  create_table "pending_actions", :force => true do |t|
    t.integer  "course_id"
    t.integer  "user_course_id"
    t.integer  "item_id"
    t.string   "item_type"
    t.boolean  "is_ignored",     :default => false
    t.boolean  "is_done",        :default => false
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  add_index "pending_actions", ["course_id"], :name => "index_pending_actions_on_course_id"
  add_index "pending_actions", ["item_id", "item_type"], :name => "index_pending_actions_on_item_id_and_item_type"
  add_index "pending_actions", ["user_course_id"], :name => "index_pending_actions_on_user_course_id"

  create_table "pending_comments", :force => true do |t|
    t.integer  "answer_id"
    t.string   "answer_type"
    t.boolean  "pending"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "course_id"
  end

  add_index "pending_comments", ["answer_id", "answer_type"], :name => "index_pending_comments_on_answer_id_and_answer_type"
  add_index "pending_comments", ["answer_id"], :name => "index_pending_comments_on_answer_id"
  add_index "pending_comments", ["course_id"], :name => "index_pending_comments_on_course_id"

  create_table "preferable_items", :force => true do |t|
    t.string   "item"
    t.string   "item_type"
    t.string   "name"
    t.string   "default_value"
    t.boolean  "default_display"
    t.string   "description"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "programming_languages", :force => true do |t|
    t.string   "name"
    t.string   "codemirror_mode"
    t.string   "version"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "cmd"
  end

  create_table "question_assessments", :force => true do |t|
    t.integer  "question_id"
    t.integer  "assessment_id"
    t.integer  "position"
    t.datetime "deleted_at"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "question_assessments", ["question_id", "assessment_id"], :name => "index_on_question_assessment"

  create_table "questions", :force => true do |t|
    t.integer  "creator_id"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "max_grade"
  end

  add_index "questions", ["creator_id"], :name => "index_questions_on_creator_id"

  create_table "queued_jobs", :force => true do |t|
    t.integer  "owner_id"
    t.string   "owner_type"
    t.integer  "delayed_job_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "job_type"
  end

  add_index "queued_jobs", ["delayed_job_id"], :name => "index_queued_jobs_on_delayed_job_id"
  add_index "queued_jobs", ["owner_id"], :name => "index_queued_jobs_on_owner_id"
  add_index "queued_jobs", ["owner_type"], :name => "index_queued_jobs_on_owner_type"

  create_table "read_marks", :force => true do |t|
    t.integer  "readable_id"
    t.integer  "user_id",                     :null => false
    t.string   "readable_type", :limit => 20, :null => false
    t.datetime "timestamp"
  end

  add_index "read_marks", ["user_id", "readable_type", "readable_id"], :name => "index_read_marks_on_user_id_and_readable_type_and_readable_id"

  create_table "requirable_requirements", :force => true do |t|
    t.integer  "requirable_id"
    t.string   "requirable_type"
    t.integer  "requirement_id"
    t.datetime "deleted_at"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "requirable_requirements", ["requirable_id", "requirable_type"], :name => "index_on_requirables"

  create_table "requirements", :force => true do |t|
    t.integer  "req_id"
    t.string   "req_type"
    t.integer  "obj_id"
    t.string   "obj_type"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "requirements", ["obj_id", "obj_type"], :name => "index_requirements_on_obj_id_and_obj_type"
  add_index "requirements", ["obj_id"], :name => "index_requirements_on_obj_id"
  add_index "requirements", ["req_id", "req_type"], :name => "index_requirements_on_req_id_and_req_type"
  add_index "requirements", ["req_id"], :name => "index_requirements_on_req_id"

  create_table "rewards", :force => true do |t|
    t.string   "icon_url"
    t.string   "title"
    t.text     "description"
    t.integer  "creator_id"
    t.integer  "course_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "rewards", ["course_id"], :name => "index_rewards_on_course_id"
  add_index "rewards", ["creator_id"], :name => "index_rewards_on_creator_id"

  create_table "role_requests", :force => true do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "organization"
    t.string   "designation"
    t.text     "reason"
  end

  add_index "role_requests", ["role_id"], :name => "index_role_requests_on_role_id"
  add_index "role_requests", ["user_id"], :name => "index_role_requests_on_user_id"

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.string   "title"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "roles", ["name"], :name => "index_roles_on_name"

  create_table "sbm_answers", :force => true do |t|
    t.integer  "sbm_id"
    t.string   "sbm_type"
    t.integer  "answer_id"
    t.string   "answer_type"
    t.boolean  "is_final"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "sbm_answers", ["answer_id"], :name => "index_sbm_answers_on_answer_id"
  add_index "sbm_answers", ["sbm_id"], :name => "index_sbm_answers_on_sbm_id"

  create_table "scribbles", :force => true do |t|
    t.text     "content",            :limit => 16777215
    t.integer  "std_course_id"
    t.integer  "scribing_answer_id"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  create_table "seen_by_users", :force => true do |t|
    t.integer  "user_course_id"
    t.integer  "obj_id"
    t.string   "obj_type"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "seen_by_users", ["obj_id", "obj_type"], :name => "index_seen_by_users_on_obj_id_and_obj_type"
  add_index "seen_by_users", ["obj_id"], :name => "index_seen_by_users_on_obj_id"
  add_index "seen_by_users", ["user_course_id", "obj_id", "obj_type"], :name => "index_seen_by_users_on_user_course_id_and_obj_id_and_obj_type", :unique => true
  add_index "seen_by_users", ["user_course_id", "obj_type"], :name => "index_seen_by_users_on_user_course_id_and_obj_type"
  add_index "seen_by_users", ["user_course_id"], :name => "index_seen_by_users_on_user_course_id"

  create_table "std_answers", :force => true do |t|
    t.text     "text"
    t.integer  "student_id"
    t.integer  "question_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.datetime "last_commented_at"
    t.integer  "std_course_id"
  end

  add_index "std_answers", ["question_id"], :name => "index_std_answers_on_question_id"
  add_index "std_answers", ["std_course_id"], :name => "index_std_answers_on_std_course_id"
  add_index "std_answers", ["student_id"], :name => "index_std_answers_on_student_id"

  create_table "std_coding_answers", :force => true do |t|
    t.text     "code"
    t.integer  "student_id"
    t.integer  "qn_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.boolean  "is_correct"
    t.integer  "std_course_id"
    t.datetime "last_commented_at"
    t.integer  "test_left"
    t.text     "result"
  end

  add_index "std_coding_answers", ["std_course_id"], :name => "index_std_coding_answers_on_std_course_id"

  create_table "std_mcq_all_answers", :force => true do |t|
    t.text     "selected_choices"
    t.integer  "student_id"
    t.integer  "mcq_id"
    t.integer  "std_course_id"
    t.text     "choices"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "std_mcq_answers", :force => true do |t|
    t.integer  "mcq_answer_id"
    t.string   "choices"
    t.integer  "student_id"
    t.integer  "mcq_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "std_course_id"
  end

  add_index "std_mcq_answers", ["mcq_answer_id"], :name => "index_std_mcq_answers_on_mcq_answer_id"
  add_index "std_mcq_answers", ["mcq_id"], :name => "index_std_mcq_answers_on_mcq_id"
  add_index "std_mcq_answers", ["std_course_id"], :name => "index_std_mcq_answers_on_std_course_id"
  add_index "std_mcq_answers", ["student_id"], :name => "index_std_mcq_answers_on_student_id"

  create_table "std_tags", :force => true do |t|
    t.integer  "std_course_id"
    t.integer  "tag_id"
    t.integer  "exp"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "std_tags", ["std_course_id"], :name => "index_std_tags_on_std_course_id"
  add_index "std_tags", ["tag_id"], :name => "index_std_tags_on_tag_id"

  create_table "submission_gradings", :force => true do |t|
    t.integer  "grader_id"
    t.integer  "total_grade"
    t.text     "comment"
    t.integer  "sbm_id"
    t.datetime "publish_at"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.string   "sbm_type"
    t.integer  "exp_transaction_id"
    t.integer  "total_exp"
    t.datetime "last_grade_updated"
    t.integer  "grader_course_id"
  end

  add_index "submission_gradings", ["exp_transaction_id"], :name => "index_submission_gradings_on_exp_transaction_id"
  add_index "submission_gradings", ["grader_course_id"], :name => "index_submission_gradings_on_grader_course_id"
  add_index "submission_gradings", ["grader_id"], :name => "index_submission_gradings_on_grader_id"
  add_index "submission_gradings", ["sbm_id"], :name => "index_submission_gradings_on_sbm_id"

  create_table "submissions", :force => true do |t|
    t.integer  "std_course_id"
    t.integer  "mission_id"
    t.datetime "open_at"
    t.datetime "submit_at"
    t.integer  "attempt"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "final_grading_id"
    t.time     "deleted_at"
    t.string   "status"
  end

  add_index "submissions", ["final_grading_id"], :name => "index_submissions_on_final_grading_id"
  add_index "submissions", ["mission_id"], :name => "index_submissions_on_mission_id"
  add_index "submissions", ["std_course_id"], :name => "index_submissions_on_std_course_id"

  create_table "survey_essay_answers", :force => true do |t|
    t.integer  "user_course_id"
    t.integer  "question_id"
    t.text     "text"
    t.time     "deleted_at"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.integer  "survey_submission_id"
  end

  add_index "survey_essay_answers", ["question_id"], :name => "index_survey_essay_answers_on_question_id"
  add_index "survey_essay_answers", ["survey_submission_id"], :name => "index_survey_essay_answers_on_survey_submission_id"
  add_index "survey_essay_answers", ["user_course_id"], :name => "index_survey_essay_answers_on_user_course_id"

  create_table "survey_mrq_answers", :force => true do |t|
    t.text     "selected_options"
    t.integer  "user_course_id"
    t.integer  "question_id"
    t.time     "deleted_at"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.integer  "option_id"
    t.integer  "survey_submission_id"
  end

  add_index "survey_mrq_answers", ["option_id"], :name => "index_survey_mrq_answers_on_option_id"
  add_index "survey_mrq_answers", ["question_id"], :name => "index_survey_mrq_answers_on_question_id"
  add_index "survey_mrq_answers", ["survey_submission_id"], :name => "index_survey_mrq_answers_on_survey_submission_id"
  add_index "survey_mrq_answers", ["user_course_id"], :name => "index_survey_mrq_answers_on_user_course_id"

  create_table "survey_question_options", :force => true do |t|
    t.integer  "question_id"
    t.text     "description"
    t.time     "deleted_at"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "pos"
    t.integer  "count"
  end

  add_index "survey_question_options", ["question_id"], :name => "index_survey_question_options_on_question_id"

  create_table "survey_question_types", :force => true do |t|
    t.string   "title"
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "survey_questions", :force => true do |t|
    t.integer  "type_id"
    t.integer  "survey_id"
    t.integer  "survey_section_id"
    t.text     "description"
    t.boolean  "publish",           :default => true
    t.integer  "max_response"
    t.integer  "pos"
    t.time     "deleted_at"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.boolean  "is_required",       :default => true
  end

  add_index "survey_questions", ["survey_id"], :name => "index_survey_questions_on_survey_id"
  add_index "survey_questions", ["survey_section_id"], :name => "index_survey_questions_on_survey_section_id"
  add_index "survey_questions", ["type_id"], :name => "index_survey_questions_on_type_id"

  create_table "survey_sections", :force => true do |t|
    t.integer  "survey_id"
    t.string   "title"
    t.text     "description"
    t.integer  "pos"
    t.boolean  "publish",     :default => true
    t.time     "deleted_at"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "survey_sections", ["survey_id"], :name => "index_survey_sections_on_survey_id"

  create_table "survey_submissions", :force => true do |t|
    t.integer  "user_course_id"
    t.integer  "survey_id"
    t.datetime "open_at"
    t.datetime "submitted_at"
    t.string   "status"
    t.time     "deleted_at"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "current_qn"
  end

  add_index "survey_submissions", ["survey_id"], :name => "index_survey_submissions_on_survey_id"
  add_index "survey_submissions", ["user_course_id"], :name => "index_survey_submissions_on_user_course_id"

  create_table "survey_types", :force => true do |t|
    t.string   "title"
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "surveys", :force => true do |t|
    t.integer  "course_id"
    t.integer  "creator_id"
    t.string   "title"
    t.text     "description"
    t.datetime "open_at"
    t.datetime "expire_at"
    t.boolean  "anonymous",    :default => false
    t.boolean  "publish",      :default => true
    t.boolean  "allow_modify", :default => true
    t.boolean  "is_contest",   :default => false
    t.time     "deleted_at"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.integer  "exp"
  end

  add_index "surveys", ["course_id"], :name => "index_surveys_on_course_id"
  add_index "surveys", ["creator_id"], :name => "index_surveys_on_creator_id"

  create_table "system_wide_announcements", :force => true do |t|
    t.integer  "creator_id"
    t.string   "subject"
    t.string   "body"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "tabs", :force => true do |t|
    t.integer  "course_id",   :null => false
    t.string   "title",       :null => false
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "owner_type",  :null => false
    t.integer  "pos"
    t.datetime "deleted_at"
  end

  add_index "tabs", ["course_id"], :name => "index_tabs_on_course_id"

  create_table "tag_groups", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "course_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.time     "deleted_at"
  end

  add_index "tag_groups", ["course_id"], :name => "index_tag_groups_on_course_id"

  create_table "taggable_tags", :force => true do |t|
    t.string   "taggable_type"
    t.integer  "taggable_id"
    t.integer  "tag_id"
    t.datetime "deleted_at"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "taggable_tags", ["taggable_id", "taggable_type"], :name => "index_taggable_tags_on_taggable_id_and_taggable_type"

  create_table "tags", :force => true do |t|
    t.string   "name"
    t.integer  "taggings_count", :default => 0
    t.text     "description"
    t.integer  "course_id"
    t.integer  "tag_group_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tags", ["name"], :name => "index_tags_on_name"
  add_index "tags", ["tag_group_id"], :name => "index_tags_on_tag_group_id"

  create_table "theme_attributes", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "value_type"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "titles", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "creator_id"
    t.integer  "course_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "titles", ["course_id"], :name => "index_titles_on_course_id"
  add_index "titles", ["creator_id"], :name => "index_titles_on_creator_id"

  create_table "training_submissions", :force => true do |t|
    t.integer  "std_course_id"
    t.integer  "training_id"
    t.integer  "current_step"
    t.datetime "open_at"
    t.datetime "submit_at"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.time     "deleted_at"
    t.float    "multiplier"
  end

  add_index "training_submissions", ["std_course_id"], :name => "index_training_submissions_on_std_course_id"
  add_index "training_submissions", ["training_id"], :name => "index_training_submissions_on_training_id"

  create_table "trainings", :force => true do |t|
    t.integer  "course_id"
    t.integer  "creator_id"
    t.string   "title"
    t.text     "description"
    t.integer  "exp"
    t.datetime "open_at"
    t.integer  "pos"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.integer  "max_grade"
    t.time     "deleted_at"
    t.integer  "bonus_exp"
    t.datetime "bonus_cutoff"
    t.boolean  "publish",      :default => true
    t.integer  "t_type",       :default => 1
    t.integer  "tab_id"
  end

  add_index "trainings", ["course_id"], :name => "index_trainings_on_course_id"
  add_index "trainings", ["creator_id"], :name => "index_trainings_on_creator_id"

  create_table "tutor_monitorings", :force => true do |t|
    t.integer  "course_id"
    t.integer  "user_course_id"
    t.integer  "average_time"
    t.integer  "std_dev"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "tutor_monitorings", ["course_id"], :name => "index_tutor_monitorings_on_course_id"
  add_index "tutor_monitorings", ["user_course_id"], :name => "index_tutor_monitorings_on_user_course_id", :unique => true

  create_table "tutorial_groups", :force => true do |t|
    t.integer  "course_id"
    t.integer  "std_course_id"
    t.integer  "tut_course_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "tutorial_groups", ["course_id"], :name => "index_tutorial_groups_on_course_id"
  add_index "tutorial_groups", ["std_course_id", "tut_course_id"], :name => "index_tutorial_groups_on_std_course_id_and_tut_course_id", :unique => true

  create_table "user_achievements", :force => true do |t|
    t.integer  "user_course_id"
    t.integer  "achievement_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.datetime "obtained_at"
  end

  add_index "user_achievements", ["achievement_id"], :name => "index_user_achievements_on_achievement_id"
  add_index "user_achievements", ["user_course_id", "achievement_id"], :name => "index_user_achievements_on_user_course_id_and_achievement_id", :unique => true
  add_index "user_achievements", ["user_course_id"], :name => "index_user_achievements_on_user_course_id"

  create_table "user_courses", :force => true do |t|
    t.integer  "user_id"
    t.integer  "course_id"
    t.integer  "exp"
    t.integer  "role_id"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.integer  "level_id"
    t.time     "deleted_at"
    t.boolean  "is_phantom",       :default => false
    t.datetime "exp_updated_at"
    t.string   "name"
    t.datetime "last_active_time"
  end

  add_index "user_courses", ["course_id"], :name => "index_user_courses_on_course_id"
  add_index "user_courses", ["level_id"], :name => "index_user_courses_on_level_id"
  add_index "user_courses", ["role_id"], :name => "index_user_courses_on_role_id"
  add_index "user_courses", ["user_id"], :name => "index_user_courses_on_user_id"

  create_table "user_rewards", :force => true do |t|
    t.integer  "user_course_id"
    t.integer  "reward_id"
    t.datetime "claimed_at"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "user_rewards", ["reward_id"], :name => "index_user_rewards_on_reward_id"
  add_index "user_rewards", ["user_course_id"], :name => "index_user_rewards_on_user_course_id"

  create_table "user_titles", :force => true do |t|
    t.integer  "user_course_id"
    t.integer  "title_id"
    t.integer  "is_using"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "user_titles", ["title_id"], :name => "index_user_titles_on_title_id"
  add_index "user_titles", ["user_course_id"], :name => "index_user_titles_on_user_course_id"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "profile_photo_url"
    t.string   "display_name"
    t.datetime "created_at",                                                       :null => false
    t.datetime "updated_at",                                                       :null => false
    t.string   "email",                                         :default => "",    :null => false
    t.string   "encrypted_password",                            :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                                 :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "system_role_id"
    t.time     "deleted_at"
    t.string   "provider"
    t.string   "uid"
    t.string   "unconfirmed_email"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.boolean  "is_logged_in",                                  :default => true
    t.boolean  "is_pending_deletion",                           :default => false
    t.boolean  "use_uploaded_picture",                          :default => false
    t.integer  "fb_publish_actions_request_count", :limit => 1, :default => 0,     :null => false
    t.string   "time_zone"
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["provider", "uid"], :name => "index_users_on_provider_and_uid"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["system_role_id"], :name => "index_users_on_system_role_id"

  create_table "votes", :force => true do |t|
    t.integer  "votable_id"
    t.string   "votable_type"
    t.integer  "voter_id"
    t.string   "voter_type"
    t.boolean  "vote_flag"
    t.string   "vote_scope"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "votes", ["votable_id", "votable_type", "vote_scope"], :name => "index_votes_on_votable_id_and_votable_type_and_vote_scope"
  add_index "votes", ["votable_id", "votable_type"], :name => "index_votes_on_votable_id_and_votable_type"
  add_index "votes", ["voter_id", "voter_type", "vote_scope"], :name => "index_votes_on_voter_id_and_voter_type_and_vote_scope"
  add_index "votes", ["voter_id", "voter_type"], :name => "index_votes_on_voter_id_and_voter_type"

end
