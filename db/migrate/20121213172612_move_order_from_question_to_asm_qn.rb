class MoveOrderFromQuestionToAsmQn < ActiveRecord::Migration
  def change
    remove_column :questions, :order
    remove_column :mcqs, :order
    add_column :asm_qns, :order, :integer
  end
end
