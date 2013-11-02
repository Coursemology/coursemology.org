Forem::ApplicationHelper.class_eval do
  def forem_format(text, *options)
    forem_no_escape_emojify(Forem.formatter.format(text))
  end

  def forem_no_escape_emojify(content)
    content.gsub(/:([a-z0-9\+\-_]+):/) do |match|
      if Emoji.names.include?($1)
        '<img alt="' + $1 + '" height="20" src="' + asset_path("emoji/#{$1}.png") + '" style="vertical-align:middle" width="20" />'
      else
        match
      end
    end.html_safe if content.present?
  end
end
