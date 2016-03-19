class SchemaCleanUp < ActiveRecord::Migration
  def drop_table_if_exists(table_name)
    drop_table table_name if ActiveRecord::Base.connection.table_exists?(table_name)
  end

  def change
    drop_table_if_exists :answer_gradings
    drop_table_if_exists :asm_qns
    drop_table_if_exists :asm_tags
    drop_table_if_exists :coding_questions
    drop_table_if_exists :forem_categories
    drop_table_if_exists :forem_category_subscriptions
    drop_table_if_exists :forem_forums
    drop_table_if_exists :forem_groups
    drop_table_if_exists :forem_memberships
    drop_table_if_exists :forem_moderator_groups
    drop_table_if_exists :forem_posts
    drop_table_if_exists :forem_subscriptions
    drop_table_if_exists :forem_topics
    drop_table_if_exists :forem_views
    drop_table_if_exists :forum_post_votes # `votes` is used.
    drop_table_if_exists :mcq_answers
    drop_table_if_exists :mcqs
    drop_table_if_exists :missions
    drop_table_if_exists :questions
    drop_table_if_exists :read_marks
    drop_table_if_exists :rewards
    drop_table_if_exists :sbm_answers
    drop_table_if_exists :std_answers
    drop_table_if_exists :std_coding_answers
    drop_table_if_exists :std_mcq_all_answers
    drop_table_if_exists :std_mcq_answers
    drop_table_if_exists :std_tags
    drop_table_if_exists :submission_gradings
    drop_table_if_exists :submissions
    drop_table_if_exists :survey_types
    drop_table_if_exists :titles
    drop_table_if_exists :training_submissions
    drop_table_if_exists :trainings
    drop_table_if_exists :user_rewards
    drop_table_if_exists :tutor_monitorings
    drop_table_if_exists :user_titles
  end
end
