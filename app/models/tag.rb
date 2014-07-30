class Tag < ActsAsTaggableOn::Tag
  acts_as_paranoid
  acts_as_duplicable
  #
  attr_accessible :description, :icon_url, :tag_group_id, :course_id
  validates_uniqueness_of :name, scope: :course_id
  #
  # scope :uncategorized, where(name: 'Uncategorized')
  #
  belongs_to :course
  belongs_to :tag_group

  before_save :assign_default_group

  def assign_default_group
    unless self.tag_group
      self.tag_group = course.tag_groups.uncategorized
    end
  end

  def self.find_or_create_by_name(name)
    named(name).first || create({name: name})
  end

  #
  # has_many :asm_tags, dependent: :destroy
  # has_many :std_tags, dependent: :destroy
  # has_many :taggable_tags, dependent: :destroy
  #
  # has_many :questions, through: :taggable_tags, source: :taggable, source_type: "Assessment::Question"
  #
  # amoeba do
  #   include_field :taggable_tags
  # end
  #
  # # before_create :init
  #
  # def self.questions
  #   Assessment::Question.
  #       joins("LEFT JOIN taggable_tags ON
  #                               taggable_tags.taggable_id = assessment_questions.id AND
  #                               taggable_tags.taggable_type = 'Assessment::Question'").
  #       where("taggable_tags.tag_id IN (?)", self.all)
  # end
  #
  # def update_max_exp
  #   self.max_exp = self.asm_tags.sum { |asm_tag| asm_tag.asm.total_exp }
  #   self.save
  # end
  #
  # def update_exp_for_std(std_course_id)
  #   exp_transactions = []
  #   self.asm_tags.each do |asm_tag|
  #     final_sbm = asm_tag.asm.get_final_sbm_by_std(std_course_id)
  #     if final_sbm
  #       final_grading = final_sbm.get_final_grading
  #       if final_grading && final_grading.exp_transaction
  #         exp_transactions << final_grading.exp_transaction
  #       end
  #     end
  #   end
  #   std_tag = self.std_tags.find_by_std_course_id(std_course_id)
  #   if !std_tag
  #     std_tag = self.std_tags.build( { std_course_id: std_course_id } )
  #   end
  #   std_tag.exp = exp_transactions.sum { |expt| expt.exp if expt }
  #   std_tag.save
  # end
  #
  # def title
  #   name
  # end
  def validates_name_uniqueness?
    false
  end
end
