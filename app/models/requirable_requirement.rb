class RequirableRequirement < ActiveRecord::Base
  EPS = 1e-5

  include AsRequirement

  belongs_to :requireable, polymorphic: true
end