class CoursemologyFormatter
  def self.format(text)
    '<p>' + sanitize(text) + '</p>'
  end

  def self.sanitize(text)
    text
  end
end