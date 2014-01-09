namespace :db do
  desc "Populate survey question option count after migration"

  task migrate_milstone: :environment do
    Course.all.each do |course|
      milestones = course.lesson_plan_milestones.order(:end_at)
      if milestones.length == 0
        next
      end
      first = milestones.first
      first.start_at = first.end_at
      first.save
      previous = first
      milestones[1, milestones.length - 1].each do |milestone|
        milestone.start_at = previous.end_at
        milestone.save
        previous = milestone
      end
    end
  end
end
