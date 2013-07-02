class CreateStdCodingAnswers < ActiveRecord::Migration
  def change
    create_table :std_coding_answers do |t|
      t.text :code
      t.integer :student_id
      t.integer :qn_id

      t.timestamps
    end
  end
end
