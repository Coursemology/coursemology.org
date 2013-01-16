class Tag < ActiveRecord::Base
  attr_accessible :course_id, :description, :icon_url, :max_exp, :name

  belongs_to :course

  has_many :asm_tags
  has_many :std_tags

  has_many :trainings, through: :asm_tags, source: :asm, source_type: "Training"

  before_create :init

  def update_max_exp
    self.max_exp = self.asm_tags.sum { |asm_tag| asm_tag.asm.exp }
    self.save
  end

  def update_exp_for_std(std_course_id)
    exp_transactions = []
    self.asm_tags.each do |asm_tag|
      final_sbm = asm_tag.asm.get_final_sbm_by_std(std_course_id)
      if final_sbm
        final_grading = final_sbm.get_final_grading
        exp_transactions << final_grading.exp_transaction
      end
    end
    std_tag = self.std_tags.find_by_std_course_id(std_course_id)
    if !std_tag
      std_tag = self.std_tags.build( { std_course_id: std_course_id } )
    end
    std_tag.exp = exp_transactions.sum { |expt| expt.exp if expt }
    std_tag.save
  end

  private
  def init
    self.max_exp ||= 0
  end
end
