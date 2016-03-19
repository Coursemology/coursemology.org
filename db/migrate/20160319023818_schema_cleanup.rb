class SchemaCleanup < ActiveRecord::Migration
  def change
    drop_table :answer_gradings
    drop_table :asm_qns
    drop_table :asm_tags
    drop_table :coding_questions
    drop_table :forem_categories
    drop_table :forem_category_subscriptions
    drop_table :forem_forums
    drop_table :forem_groups
    drop_table :forem_memberships
    drop_table :forem_moderator_groups
    drop_table :forem_posts
    drop_table :forem_subscriptions
    drop_table :forem_topics
    drop_table :forem_views
    drop_table :forum_post_votes # `votes` is used.
    drop_table :mcq_answers
    drop_table :mcqs
    drop_table :missions
    drop_table :questions
    drop_table :read_marks
    drop_table :rewards
    drop_table :sbm_answers
    drop_table :std_answers
    drop_table :std_coding_answers
    drop_table :std_mcq_all_answers
    drop_table :std_mcq_answers
    drop_table :std_tags
    drop_table :submission_gradings
    drop_table :submissions
    drop_table :survey_types
    drop_table :titles
    drop_table :training_submissions
    drop_table :trainings
    drop_table :user_rewards
    drop_table :tutor_monitorings
    drop_table :user_titles
  end
end
