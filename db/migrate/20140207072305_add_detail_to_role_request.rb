class AddDetailToRoleRequest < ActiveRecord::Migration
  def change
    add_column :role_requests, :organization, :string
    add_column :role_requests, :designation, :string
    add_column :role_requests, :reason, :text
  end
end
