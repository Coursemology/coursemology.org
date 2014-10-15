class AddJobTypeToQueuedJobs < ActiveRecord::Migration
  def change
    add_column :queued_jobs, :job_type, :string
  end
end
