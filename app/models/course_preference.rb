class CoursePreference < ActiveRecord::Base
  attr_accessible :course_id, :preferable_item_id, :prefer_value, :display

  belongs_to  :course
  belongs_to  :preferable_item

  scope :training_reattempt, where(preferable_item_id: PreferableItem.training_reattempt.first)

end
