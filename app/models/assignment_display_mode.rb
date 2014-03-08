class AssignmentDisplayMode <  ActiveRecord::Base
  attr_accessible :title, :description

  scope :single, where(title: 'Single Page')
  scope :tab, where(title: 'Tab')

  def self.single_page
    AssignmentDisplayMode.single.first
  end

  def self.tab_mode
    AssignmentDisplayMode.tab.first
  end
end