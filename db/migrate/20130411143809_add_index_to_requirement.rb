class AddIndexToRequirement < ActiveRecord::Migration
  def change
    add_index :requirements, :req_id
    add_index :requirements, :obj_id
  end
end
