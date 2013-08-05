
class MailMonitorPlugin < Delayed::Plugin
  callbacks do |lifecycle|
    lifecycle.after(:perform) do |worker, job|
      queue = QueuedJob.where(delayed_job_id: job.id).first
      if queue
        QueuedJob.delete(queue)
      end
    end
  end
end

