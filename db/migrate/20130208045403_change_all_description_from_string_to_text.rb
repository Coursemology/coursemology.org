class ChangeAllDescriptionFromStringToText < ActiveRecord::Migration
  def change
    change_column :courses, :description, :text
    change_column :roles, :description, :text

    change_column :missions, :description, :text
    change_column :quizzes, :description, :text
    change_column :trainings, :description, :text

    change_column :questions, :description, :text
    change_column :mcqs, :description, :text

    change_column :tag_groups, :description, :text
    change_column :tags, :description, :text

    change_column :theme_attributes, :description, :text

    change_column :actions, :description, :text

    change_column :titles, :description, :text
    change_column :achievements, :description, :text
    change_column :rewards, :description, :text

    change_column :mcq_answers, :text, :text
    change_column :mcq_answers, :explanation, :text
    change_column :std_answers, :text, :text
    change_column :submission_gradings, :comment, :text
    change_column :answer_gradings, :comment, :text
  end
end
