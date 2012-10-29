class CreateWrittenQuestions < ActiveRecord::Migration
  def change
    create_table :written_questions do |t|
      t.integer :creator_id
      t.integer :assignment_id
      t.string :description
      t.integer :order

      t.timestamps
    end
  end
end
