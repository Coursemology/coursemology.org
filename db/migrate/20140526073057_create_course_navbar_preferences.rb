class CreateCourseNavbarPreferences < ActiveRecord::Migration
  def change
    create_table :course_navbar_preferences do |t|
      t.references  :course
      t.references  :navbar_preferable_item
      t.references  :navbar_link_type
      t.string  :item
      t.string  :name
      t.boolean :is_displayed
      t.boolean :is_enabled
      t.string  :description
      t.string  :link_to
      t.integer :pos

      t.timestamps
    end

    add_index :course_navbar_preferences, :course_id
    add_index :course_navbar_preferences, [:course_id, :navbar_preferable_item_id], name: 'index_cnp_on_course_id_and_navbar_preferable_item_id'
  end
end
