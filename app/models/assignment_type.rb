class AssignmentType < ActiveRecord::Base
  attr_accessible :title, :description

  def self.main
    AssignmentType.find_by_title('Main')
  end

  def self.extra
    AssignmentType.find_by_title('Extra')
  end
end
