class CreateAssignmentDisplayMode < ActiveRecord::Migration
  def change
    create_table :assignment_display_modes do |t|
      t.string :title
      t.string :description
    end
  end
end
