class TaggableTag < ActiveRecord::Base
  acts_as_duplicable

  belongs_to  :taggable, polymorphic: true
  belongs_to  :tag
end