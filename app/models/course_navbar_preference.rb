class CourseNavbarPreference < ActiveRecord::Base
  attr_accessible :item, :name, :is_displayed, :is_enabled, :pos, :link_to
  belongs_to :navbar_link_type
  belongs_to :course
  belongs_to :navbar_preferable_item

  after_save :sweep_navbar_cache


  def sweep_navbar_cache
    Role.all.each do |role|
      Rails.cache.delete("nav_items_#{course_id}_#{role.id}")
    end
  end
end
