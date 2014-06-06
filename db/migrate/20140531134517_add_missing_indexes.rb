class AddMissingIndexes < ActiveRecord::Migration
  def change
    add_index :trainings, :tab_id
    add_index :mass_enrollment_emails, :course_id
    add_index :mass_enrollment_emails, :delayed_job_id
    add_index :comics, :course_id
    add_index :comics, :dependent_mission_id
    add_index :comics, :next_mission_id
    add_index :material_folders, :parent_folder_id
    add_index :material_folders, :course_id
    add_index :missions, :dependent_id
    add_index :missions, :display_mode
    add_index :forum_forums, :course_id
    add_index :coding_questions, :creator_id
    add_index :coding_questions, :include_sol_qn_id
    add_index :comment_topics, :course_id
    add_index :tutorial_groups, :course_id
    add_index :lesson_plan_milestones, :course_id
    add_index :lesson_plan_milestones, :creator_id
    add_index :surveys, :creator_id
    add_index :survey_essay_answers, :user_course_id
    add_index :survey_essay_answers, :question_id
    add_index :survey_essay_answers, :survey_submission_id
    add_index :survey_mrq_answers, :option_id
    add_index :survey_mrq_answers, :survey_submission_id
    add_index :survey_questions, :type_id
    add_index :tabs, :course_id
    add_index :requirements, [:obj_id, :obj_type]
    add_index :requirements, [:req_id, :req_type]
    add_index :comic_pages, :comic_id
    add_index :std_coding_answers, :student_id
    add_index :std_coding_answers, :qn_id
    add_index :std_mcq_all_answers, :student_id
    add_index :std_mcq_all_answers, :std_course_id
    add_index :std_mcq_all_answers, :mcq_id
    add_index :submission_gradings, [:sbm_id, :sbm_type]
    add_index :sbm_answers, [:sbm_id, :sbm_type]
    add_index :sbm_answers, [:answer_id, :answer_type]
    add_index :pending_comments, [:answer_id, :answer_type]
    add_index :pending_actions, [:item_id, :item_type]
    add_index :pending_actions, :course_id
    add_index :notifications, :action_id
    add_index :notifications, [:obj_id, :obj_type]
    add_index :materials, :folder_id
    add_index :lesson_plan_entries, :course_id
    add_index :lesson_plan_entries, :creator_id
    add_index :forum_topic_subscriptions, :topic_id
    add_index :forum_topic_subscriptions, :user_id
    add_index :forum_forum_subscriptions, :forum_id
    add_index :forum_forum_subscriptions, :user_id
    add_index :file_uploads, [:owner_id, :owner_type]
    add_index :file_uploads, :creator_id
    add_index :enroll_requests, :user_id
    add_index :duplicate_logs, :user_id
    add_index :duplicate_logs, :dest_course_id
    add_index :duplicate_logs, [:dest_obj_id, :dest_obj_type]
    add_index :duplicate_logs, :origin_course_id
    add_index :duplicate_logs, [:origin_obj_id, :origin_obj_type]
    add_index :course_theme_attributes, :theme_attribute_id
    add_index :asm_tags, [:asm_id, :asm_type]
    add_index :asm_qns, [:qn_id, :qn_type]
    add_index :answer_gradings, [:student_answer_id, :student_answer_type], name: :index_on_student_answer
    add_index :activities, :action_id
    add_index :activities, :actor_course_id
    add_index :activities, :target_course_id
    add_index :activities, [:obj_id, :obj_type]
    add_index :forum_topic_views, :user_id
    add_index :lesson_plan_resources, :lesson_plan_entry_id
    add_index :lesson_plan_resources, [:obj_id, :obj_type]
  end
end
