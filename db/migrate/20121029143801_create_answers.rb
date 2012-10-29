class CreateAnswers < ActiveRecord::Migration
  def change
    create_table :answers do |t|
      t.integer :credtor_id
      t.integer :question_id
      t.string :text
      t.string :explanation

      t.timestamps
    end
  end
end
