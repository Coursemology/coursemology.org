class Role < ActiveRecord::Base
  attr_accessible :description, :title
  attr_accessible :name

  scope :shared, where(name: 'shared')
  scope :student, where(name: 'student')
  scope :lecturer, where(name: 'lecturer')
  scope :admin, where(name: 'admin')
end
