class CreateScribbles < ActiveRecord::Migration
  def change
    create_table :scribbles do |t|
      t.text :content
      t.references :std_course
      t.references :scribing_answer

      t.timestamps
    end
  end
end
