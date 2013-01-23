class TagGroup < ActiveRecord::Base
  attr_accessible :course_id, :description, :name

  belongs_to :course

  has_many :tags
end
