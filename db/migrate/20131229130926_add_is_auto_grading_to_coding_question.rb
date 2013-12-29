class AddIsAutoGradingToCodingQuestion < ActiveRecord::Migration
  def change
    add_column :coding_questions, :is_auto_grading, :boolean, default: false
  end
end
