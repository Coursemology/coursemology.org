class QueuedJob < ActiveRecord::Base
  attr_accessible :owner_id, :owner_type, :job_type, :delayed_job_id

  belongs_to :owner, polymorphic: true
  belongs_to :delayed_job, dependent: :destroy

end
