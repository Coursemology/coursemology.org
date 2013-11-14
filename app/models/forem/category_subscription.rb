module Forem
  class CategorySubscription < ActiveRecord::Base
    belongs_to :category
    belongs_to :subscriber, :class_name => Forem.user_class.to_s

    validates :subscriber_id, :presence => true

    attr_accessible :subscriber_id

    def send_notification(topic_id)
      # If a user cannot be found, then no-op
      # This will happen if the user record has been deleted.
      if subscriber.present?
        #SubscriptionMailer.topic_reply(topic_id, subscriber.id).
        puts topic_id
        puts subscriber.id
      end
    end
  end
end
