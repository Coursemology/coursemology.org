class LessonPlanEntry < ActiveRecord::Base
  attr_accessible :title, :entry_type, :description, :start_at, :end_at, :location

  validates_with DateValidator, fields: [:start_at, :end_at]

  belongs_to :course
  belongs_to :creator, class_name: "User"
  has_many :resources, class_name: "LessonPlanResource"

  # Creates a virtual item of this class that is backed by some other data store.
  def self.create_virtual
    (Class.new do
      def initialize
        @title = @description = @real_type = @start_at = @end_at = nil
        @resources = []
      end

      def title
        @title
      end
      def title=(title)
        @title = title
      end
      def entry_type
        3
      end
      def entry_real_type
        @real_type
      end
      def entry_real_type=(type)
        @real_type = type
      end
      def description
        @description
      end
      def description=(description)
        @description = description
      end
      def start_at
        @start_at
      end
      def start_at=(start_at)
        @start_at = start_at
      end
      def end_at
        @end_at
      end
      def end_at=(end_at)
        @end_at = end_at
      end
      def resources
        @resources
      end
      def resources=(resources)
        @resources = resources
      end
      def location
        nil
      end

      # Extra property that real entries do not have, so we can jump to them.
      def url
        @url
      end
      def url=(url)
        @url = url
      end
      
      def is_virtual
        true
      end
    end).new
  end

  # Defines all the types
  ENTRY_TYPES = [
    ['Lecture', 0],
    ['Recitation', 1],
    ['Tutorial', 2],
    ['Other', 3]
  ]

  def is_virtual
    false
  end
end
