class SbmAnswer < ActiveRecord::Base
  attr_accessible :answer_id, :answer_type, :is_final, :sbm_id, :sbm_type

  scope :final, where(:is_final => true)

  belongs_to :sbm, polymorphic: true
  belongs_to :answer, polymorphic: true
end
