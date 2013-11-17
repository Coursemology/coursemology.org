module Forem
  class CategorySubscription < ActiveRecord::Base
    belongs_to :category
    belongs_to :subscriber, :class_name => Forem.user_class.to_s

    default_scope {includes(:subscriber)}

    validates :subscriber_id, presence: true, uniqueness: {scope: :category_id}

    attr_accessible :subscriber_id, :category_id, :is_digest

    def send_notification(post_id)
      # If a user cannot be found, then no-op
      # This will happen if the user record has been deleted.

      if subscriber.present?
        SubscriptionMailer.delay.new_post(post_id, subscriber.id)
      end
    end
  end
end
