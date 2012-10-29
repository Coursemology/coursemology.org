class CreateMcqs < ActiveRecord::Migration
  def change
    create_table :mcqs do |t|
      t.integer :creator_id
      t.integer :assignment_id
      t.string :description
      t.integer :order
      t.integer :correct_answer_id

      t.timestamps
    end
  end
end
