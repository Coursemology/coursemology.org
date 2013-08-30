class CreateAssignmentTypes < ActiveRecord::Migration
  def change
    create_table :assignment_types do |t|
      t.string  :title
      t.string  :description

      t.timestamps
    end
  end
end
