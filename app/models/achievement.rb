class Achievement < ActiveRecord::Base
  attr_accessible :course_id, :creator_id, :description, :icon_url, :title

  belongs_to :course

  has_many :requirements, as: :obj
  has_many :asm_reqs, through: :requirements, source: :req, source_type: "AsmReq"
  has_many :lvl_reqs, through: :requirements, source: :req, source_type: "Level"
  has_many :ach_reqs, through: :requirements, source: :req, source_type: "Achievement"
end
