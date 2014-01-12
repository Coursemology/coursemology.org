namespace :db do

  task update_submission_status: :environment do
    TrainingSubmission.all.each do |sbm|
      if sbm.status
        puts "Next " + sbm.status
        next
      end
      if sbm.done?
        sbm.set_graded
        puts "graded " + sbm.id.to_s
      else
        sbm.set_submitted(nil, false)
        puts "submitted " + sbm.id.to_s
      end
    end
  end
end
