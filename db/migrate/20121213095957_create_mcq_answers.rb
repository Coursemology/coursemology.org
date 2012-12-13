class CreateMcqAnswers < ActiveRecord::Migration
  def change
    create_table :mcq_answers do |t|
      t.integer :mcq_id
      t.string :text
      t.integer :creator_id
      t.string :explanation
      t.boolean :is_correct

      t.timestamps
    end
  end
end
