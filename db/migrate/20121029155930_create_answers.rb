class CreateAnswers < ActiveRecord::Migration
  def change
    create_table :answers do |t|
      t.integer :question_id
      t.string :text
      t.integer :creator_id
      t.string :explanation

      t.timestamps
    end
  end
end
