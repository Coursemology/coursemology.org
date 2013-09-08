class CreateTutorMonitorings < ActiveRecord::Migration
  def change
    create_table :tutor_monitorings do |t|
      t.integer :course_id
      t.integer :user_course_id
      t.integer :average_time
      t.integer :std_dev

      t.timestamps
    end

    add_index :tutor_monitorings, :course_id
    add_index :tutor_monitorings, :user_course_id, :unique => true

  end
end
