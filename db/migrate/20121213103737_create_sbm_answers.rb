class CreateSbmAnswers < ActiveRecord::Migration
  def change
    create_table :sbm_answers do |t|
      t.integer :sbm_id
      t.string :sbm_type
      t.integer :answer_id
      t.string :answer_type
      t.boolean :is_final

      t.timestamps
    end
  end
end
