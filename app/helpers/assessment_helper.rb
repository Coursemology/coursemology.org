module AssessmentHelper
  # Given a string of text and a list of keywords, highlights each
  # keyword occurrence with a <span> tag.
  def highlight_keywords(original, keywords)
    highlighted = original.dup
    keywords.each do |keyword|
      highlighted.gsub!(keyword_regex(keyword), content_tag(:mark, '\0').html_safe)
    end
    highlighted
  end
end
