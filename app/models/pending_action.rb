class PendingAction < ActiveRecord::Base
  # attr_accessible :title, :body

  attr_accessible :item_type, :item_id, :is_ignored, :is_done

  scope :to_show, where(is_done: false, is_ignored: false)

  belongs_to :item, polymorphic: true
  belongs_to :course
  belongs_to :user_course

  def set_done
    self.is_done = true
    self.save
  end

end
