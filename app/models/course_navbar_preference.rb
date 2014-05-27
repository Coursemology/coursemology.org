class CourseNavbarPreference < ActiveRecord::Base
  # attr_accessible :title, :body
  attr_accessible :item, :name, :is_displayed, :is_enabled, :pos, :link_to
  belongs_to :navbar_link_type
  belongs_to :course
  belongs_to :navbar_preferable_item


  # def announcement
  #
  # end
end
