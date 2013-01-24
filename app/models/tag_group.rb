class TagGroup < ActiveRecord::Base
  acts_as_paranoid

  attr_accessible :course_id, :description, :name

  belongs_to :course

  has_many :tags, dependent: :destroy
end
