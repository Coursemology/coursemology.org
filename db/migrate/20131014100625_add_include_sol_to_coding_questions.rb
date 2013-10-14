class AddIncludeSolToCodingQuestions < ActiveRecord::Migration
  def change
    add_column :coding_questions, :include_sol_qn_id, :integer
  end
end