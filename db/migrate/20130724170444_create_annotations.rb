class CreateAnnotations < ActiveRecord::Migration
  def change
    create_table :annotations do |t|
      t.integer :annotable_id
      t.string  :annotable_type
      t.integer :line_start
      t.integer :line_end
      t.integer :user_course_id
      t.text    :text

      t.timestamps
    end
  end
end
