class Tag < ActiveRecord::Base
  attr_accessible :course_id, :description, :icon_url, :max_exp, :name

  belongs_to :course

  after_initialize :init

  private
  def init
    self.max_exp ||= 0
  end
end
