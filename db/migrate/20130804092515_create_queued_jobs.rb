class CreateQueuedJobs < ActiveRecord::Migration
  def change
    create_table :queued_jobs do |t|
      t.integer   :owner_id
      t.string    :owner_type
      t.integer   :delayed_job_id
      t.timestamps
    end

    add_index :queued_jobs, :owner_id
    add_index :queued_jobs, :owner_type
    add_index :queued_jobs, :delayed_job_id
  end
end
