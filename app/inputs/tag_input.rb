class TagInput < SimpleForm::Inputs::StringInput
  def input
    objects = object.send(attribute_name) if object.respond_to? attribute_name
    input_html_options[:value] ||= objects.map {|o| {id: o.id, name: o.name}}.to_json
    input_html_options[:type] = 'tag'
    input_html_options[:x] = 'tag'
    input_html_options[:url] = options.delete(:url)
    template.content_tag :div, class: input_html_options[:class] do
      super # leave StringInput do the real rendering
    end
  end
end