namespace :db do
  desc "populate existing courses with preference"

  task fix_last_comment_at: :environment do
    CommentTopic.all.each do |topic|
      unless topic.last_commented_at
        topic.last_commented_at = topic.created_at
        topic.save
      end
    end
  end
end
