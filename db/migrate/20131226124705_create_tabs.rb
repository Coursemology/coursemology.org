class CreateTabs < ActiveRecord::Migration
  def change
    create_table :tabs do |t|
      t.integer :course_id, :null => false
      t.string  :type,  :null => false
      t.string  :title, :null => false
      t.text    :description

      t.timestamps
    end
  end
end
