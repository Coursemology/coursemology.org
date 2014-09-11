namespace :user_achievement do
  desc "set obtain date to submitted date or create_at"
  task :set_obtain_date => :environment do
    UserAchievement.all.each do |uach|
      obtained_at = obtained_date(uach.achievement, uach.user_course_id)
      uach.obtained_at ||=  obtained_at || uach.created_at
      uach.save
    end
  end

  def obtained_date(achievement, user_course_id)
    puts achievement.inspect
    puts user_course_id
    submission = Assessment.joins(:as_asm_reqs)
    .where("asm_reqs.id IN (?)", achievement.requirements.asm_req.pluck(:req_id)).submissions
    .where(std_course_id: user_course_id)
    .order("submitted_at DESC").first
    submission.submitted_at if submission
  end
end
