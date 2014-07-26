module AssessmentModule

  def self.included(base)
    base.class_eval do
      before_update :clean_up_description, :if => :description_changed?
    end
  end

  def get_title(n)
    title && !title.empty? ? title : "Question #{n}"
  end

  # Clean up messed html tags
  # Copying code from TextEditor or Sublime into the wysihtml5 editor in Chrome
  # causes the editor to insert divs around every line. This function removes
  # the divs and uses br to break the lines.
  def clean_up_description
    result = description.gsub(/\[mc\](.+?)\[\/mc\]/m) do
      code = $1
      html = Nokogiri::HTML(code)
      stripped_children = html.search('body').children.map do |e|
        if e.inner_html == "<br>" || e.inner_html == "</br>"
          e.inner_html
        else
          e.inner_html + "<br>"
        end
      end
      "[mc]" + stripped_children.join + "[/mc]"
    end
    self.description = result
  end
end
