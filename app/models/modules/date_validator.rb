class DateValidator < ActiveModel::Validator
  def initialize(options)
    super
    @fields = options[:fields]
  end
  
  def validate(record)
    if record.send(@fields[0]) > record.send(@fields[1])
      record.errors[:base] << "End time should be after start time."
    end
  end
end