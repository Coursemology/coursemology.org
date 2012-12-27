class ChangeOrderToPos < ActiveRecord::Migration
  def up
    rename_column :asm_qns, :order, :pos
    rename_column :missions, :order, :pos
    rename_column :quizzes, :order, :pos
    rename_column :trainings, :order, :pos
  end
end
