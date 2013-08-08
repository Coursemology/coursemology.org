namespace :db do
  desc "populate existing subscriptions for existing comments"

  task populate_comment_subscriptions: :environment do
    Comment.all.each do |comment|
      puts comment.to_json
      CommentSubscription.populate_subscription(comment)
    end
  end
end
