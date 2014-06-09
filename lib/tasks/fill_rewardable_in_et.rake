namespace :db do
  desc "fill rewardable_id and rewardable_type in exp transaction table"

  task fill_rewardable_in_et: :environment do
    SubmissionGrading.includes(:exp_transaction).each do |sg|
      et = sg.exp_transaction
      unless et
        next
      end

      if et.rewardable_type
        next
      end
      sbm = sg.sbm
      if sbm.class == Submission
        et.rewardable = sbm.mission
      end

      if sbm.class == TrainingSubmission
        et.rewardable = sbm.training
      end

      et.save
    end
  end
end
