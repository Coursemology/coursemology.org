class TagGroup < ActiveRecord::Base
  acts_as_paranoid

  attr_accessible :course_id, :description, :name

  validates_presence_of :name
  validates_uniqueness_of :name, scope: :course_id

  belongs_to :course

  has_many :tags, dependent: :destroy

  amoeba do
    include_field :tags
  end

  def self.uncategorized
     self.where(name: 'Uncategorized').first
  end

  def title
    name
  end
end
