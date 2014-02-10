namespace :db do

  task populate_pending_actions: :environment do
    Course.all.each do |course|
      (course.missions + course.trainings + course.surveys).each do |item|
        if item.open_at > Time.now
          delayed_job = Delayed::Job.enqueue(
              BackgroundJob.new(course.id, PendingAction.to_s, item.class.to_s, item.id),
              run_at: item.open_at)
          item.queued_jobs.create(delayed_job_id: delayed_job.id)
        else
          if item.class == Mission
            ucs = (course.user_courses.student - item.submissions.map {|sub| sub.std_course })
          elsif item.class == Training
            ucs = (course.user_courses.student - item.training_submissions.select {|sub| sub.graded? }.map {|sub| sub.std_course })
          else
            ucs = course.user_courses.student - item.survey_submissions.select {|sub| sub.submitted? }.map {|sub| sub.user_course }
          end

          ucs.each do |uc|
            pending_act = uc.pending_actions.build
            pending_act.course = course
            pending_act.item_type = item.class.to_s
            pending_act.item_id = item.id
            pending_act.save
          end
        end
      end
    end
  end
end
