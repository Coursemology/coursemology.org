class AddMaterialsPermissions < ActiveRecord::Migration
  def change
    add_column :material_folders, :open_at, :datetime, :after => :description
    add_column :material_folders, :close_at, :datetime, :after => :open_at
    add_column :material_folders, :can_student_upload, :boolean, :after => :close_at, :default => false
  end
end
