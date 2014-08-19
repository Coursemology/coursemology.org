class Tag < ActiveRecord::Base
  acts_as_paranoid
  acts_as_duplicable

  attr_accessible :name, :description, :icon_url, :tag_group_id, :course_id
  #TODO, validates_uniqueness_of doesn't work when create new questions
  # validates_uniqueness_of :name, scope: [:course_id]

  belongs_to :course
  belongs_to :tag_group

  has_many :taggings, dependent: :destroy, class_name: 'TaggableTag'

  before_save :assign_default_group

  def assign_default_group
    unless self.tag_group
      self.tag_group = course.tag_groups.uncategorized
    end
  end

  #adopted from gem: acts-as-taggble-on
  def self.named_any(list)
    clause = list.map { |tag|
      sanitize_sql(['LOWER(tags.name) = LOWER(?)', as_8bit_ascii(unicode_downcase(tag))])
    }.join(' OR ')
    where(clause)
  end

  def self.find_or_create_all_with_like_by_name(course_id, *list)
    list = Array(list).flatten

    return [] if list.empty?

    existing_tags = named_any(list)

    list.map do |tag_name|
      comparable_tag_name = comparable_name(tag_name)
      existing_tag = existing_tags.find { |tag| comparable_name(tag.name) == comparable_tag_name }
      begin
        existing_tag || create({name: tag_name, course_id: course_id})
      rescue ActiveRecord::RecordNotUnique
        # Postgres aborts the current transaction with
        # PG::InFailedSqlTransaction: ERROR:  current transaction is aborted, commands ignored until end of transaction block
        # so we have to rollback this transaction
        puts "existing"
        raise DuplicateTagError.new("'#{tag_name}' has already been taken")
      end
    end
  end

  #
  # has_many :asm_tags, dependent: :destroy
  # has_many :std_tags, dependent: :destroy
  has_many :taggings, class_name:"TaggableTag", dependent: :destroy
  #
  has_many :questions, through: :taggings, source: :taggable, source_type: "Assessment::Question"

  amoeba do
    include_field :taggings
  end

  def self.max_exp
    qa = QuestionAssessment
    aq = Assessment::Question
    aa = Assessment
    tt = TaggableTag
    select = "SELECT #{tt.table_name}.tag_id," +
        " SUM((#{aa.table_name}.exp + COALESCE(#{aa.table_name}.bonus_exp, 0)) * #{aq.table_name}.max_grade / #{aa.table_name}.max_grade) as max_exp FROM"

    question_join = " #{aq.table_name} JOIN #{tt.table_name} ON #{aq.table_name}.#{aq.primary_key} = #{tt.table_name}.taggable_id" +
        " AND #{tt.table_name}.taggable_type = #{quote_value(aq.name, nil)} "

    assessments_join = " JOIN #{qa.table_name} ON" +
        " #{qa.table_name}.question_id = #{aq.table_name}.#{aq.primary_key}" +
        " JOIN #{aa.table_name} ON #{aa.table_name}.#{aa.primary_key} = #{qa.table_name}.assessment_id"

    where_ = " WHERE #{tt.table_name}.tag_id IN (#{self.all.map(&:id).join(",")})"
    group_by = " GROUP BY #{tt.table_name}.tag_id"


    ActiveRecord::Base.connection.
        select(select + question_join + assessments_join + where_ + group_by).
        map {|x| {x["tag_id"] => x["max_exp"]}}.
        reduce({}, :merge)
  end

  def self.exp_earned(uc)
    sql = "SELECT SUM((et.exp * aq.max_grade / aa.max_grade) * (aag.grade / aq.max_grade)) as exp, tag_id FROM assessment_questions aq INNER JOIN taggable_tags tt" +
        " ON tt.taggable_id = aq.id AND tt.taggable_type = 'Assessment::Question'" +
        " INNER JOIN question_assessments qa ON qa.question_id = aq.id" +
        " INNER JOIN assessments aa ON aa.id = qa.assessment_id" +
        " LEFT JOIN assessment_answers aaa ON aaa.question_id = aq.id" +
        " INNER JOIN assessment_answer_gradings aag ON aaa.id = aag.answer_id" +
        " INNER JOIN assessment_gradings ags ON aag.grading_id = ags.id" +
        " INNER JOIN exp_transactions et ON ags.exp_transaction_id = et.id" +
        " where tt.tag_id IN (#{self.all.map(&:id).join(",")})" +
        " and aaa.std_course_id = #{uc.id}" +
        " GROUP by tag_id"
    ActiveRecord::Base.connection.select(sql).
        map {|x| {x["tag_id"] => x["exp"]}}.
        reduce({}, :merge)
  end
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
  def title
    name
  end

  class << self
    private

    def comparable_name(str)
      unicode_downcase(str.to_s)
    end

    def binary
      'BINARY '
    end

    def unicode_downcase(string)
      if ActiveSupport::Multibyte::Unicode.respond_to?(:downcase)
        ActiveSupport::Multibyte::Unicode.downcase(string)
      else
        ActiveSupport::Multibyte::Chars.new(string).downcase.to_s
      end
    end

    def as_8bit_ascii(string)
      if defined?(Encoding)
        string.to_s.dup.force_encoding('BINARY')
      else
        string.to_s.mb_chars
      end
    end
  end
end
