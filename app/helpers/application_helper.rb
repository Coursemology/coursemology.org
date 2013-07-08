module ApplicationHelper
  require 'htmlentities'

  def date_mdY(date)
    if date.nil?
      ""
    else
      date.strftime("%d-%m-%Y")
    end
  end

  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def style_format(str, html_safe = true, lang='python')
    if str.to_s.length > 0
      unless html_safe
        str = HTMLEntities.new.encode(str)
      end
      str = str.gsub(/\[b\](.+?)\[\/b\]/m,'<strong>\1</strong>')
      str = str.gsub(/\[c\](.+?)\[\/c\]/m,'<span class="jfdiCode cm-s-molokai ' << lang << 'Code">\1</span>')
      str = str.gsub(/\[mc\](.+?)\[\/mc\]/m,'<pre class="jfdiCode"><div class="jfdiCode cm-s-molokai ' << lang << 'Code">\1</div></pre>')
      str.html_safe
    end
  end
end
