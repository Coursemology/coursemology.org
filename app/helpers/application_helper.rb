module ApplicationHelper
  require 'htmlentities'

  def date_mdY(date)
    if date.nil?
      ""
    else
      date.strftime("%d-%m-%Y")
    end
  end

  def datetime_format(datetime)
    if datetime.nil?
      ""
    else
      datetime.strftime("%d-%m-%Y %H:%M:%S")
    end
  end

  def datetime_no_seconds(datetime)
    if datetime.nil?
      ""
    else
      datetime.strftime("%d %b %Y %H:%M")
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

  def self.style_format(str, html_safe = true, lang='python')
    if str.to_s.length > 0
      unless html_safe
        str = HTMLEntities.new.encode(str)
      end
      str = str.gsub(/\[b\](.+?)\[\/b\]/m,'<strong>\1</strong>')
      str = str.gsub(/\[c\](.+?)\[\/c\]/m,'<div class="cos_code"><span class="jfdiCode cm-s-molokai ' << lang << 'Code">\1</span></div>')
      str = str.gsub(/\[mc\](.+?)\[\/mc\]/m){'<div class="cos_code"><pre class="jfdiCode"><div class="jfdiCode cm-s-molokai ' << lang << 'Code">'<< $1.gsub(/<br>/,'
') <<'</div></pre></div>'}
      return str.html_safe
    end
    ""
  end

  def style_format(str, html_safe = true, lang='python')
    ApplicationHelper.style_format(str,html_safe,lang)
  end


  #overwrite to customize display of error messages
  def devise_error_messages!
    return "" if resource.errors.empty?

    messages = resource.errors.full_messages.map { |msg| content_tag(:li,"* ".msg) }.join
    sentence = I18n.t("errors.messages.not_saved",
                      :count => resource.errors.count,
                      :resource => resource.class.model_name.human.downcase)

    html = <<-HTML
    <div id="error_explanation">
      <div class="alert alert-error">
      #{sentence}
      </div>
      <ul>#{messages}</ul>
    </div>
    HTML

    html.html_safe
  end

  def sortable(column, url, params = "", title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"

    if css_class && sort_direction == "asc"
      icon = '<i class="icon-chevron-up"></i>'
    elsif css_class && sort_direction == 'desc'
      icon = '<i class="icon-chevron-down"></i>'
    else
      icon = ''
    end
    "<a href='#{url}?#{params}&sort=#{column}&direction=#{direction}' >#{title} #{icon}</a>".html_safe
  end
end
