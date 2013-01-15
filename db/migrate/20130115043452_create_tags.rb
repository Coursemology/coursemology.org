class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :name
      t.string :description
      t.integer :course_id
      t.string :icon_url
      t.integer :max_exp

      t.timestamps
    end
  end
end
