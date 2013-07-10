class Role < ActiveRecord::Base
  attr_accessible :description, :title
  attr_accessible :name

  scope :shared, where(name: 'shared')
  scope :student, where(name: 'student')
  scope :lecturer, where(name: 'lecturer')
  scope :admin, where(name: 'admin')
  scope :tutor, where(name:'ta')

  def self.get_stuff_roles
    roles = []
    roles << Role.find_by_name('lecturer')  << Role.find_by_name('ta')
  end

end
