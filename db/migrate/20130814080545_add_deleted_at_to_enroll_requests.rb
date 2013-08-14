class AddDeletedAtToEnrollRequests < ActiveRecord::Migration
  def change
    add_column :enroll_requests, :deleted_at, :time
  end
end
