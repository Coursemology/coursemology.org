class Role < ActiveRecord::Base
  attr_accessible :description, :title
  attr_accessible :name
end
