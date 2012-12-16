class Requirement < ActiveRecord::Base
  attr_accessible :obj_id, :obj_type, :req_id, :req_type

  belongs_to :obj, polymorphic: true
  belongs_to :req, polymorphic: true
end
