module ApplicationHelper
  require 'htmlentities'

  def self.date_mdY(date)
    if date.nil?
      ""
    else
      date.strftime("%d-%m-%Y")
    end
  end

  def date_mdY(date)
    ApplicationHelper.date_mdY(date)
  end

  def self.datetime_format(datetime)
    if datetime.nil?
      ""
    else
      datetime.strftime("%d-%m-%Y %H:%M")
    end
  end

  def datetime_format(datetime)
    ApplicationHelper.datetime_format(datetime)
  end

  def datetime_no_seconds(datetime)
    if datetime.nil?
      ""
    else
      datetime.strftime("%d %b %Y %H:%M")
    end
  end

  def datetime_no_seconds_no_year(datetime)
    if datetime.nil?
      ""
    else
      datetime.strftime("%d %b %H:%M")
    end
  end

  def datetime_iso(datetime)
    if datetime.nil?
      ''
    else
      datetime.iso8601(2)
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
    # TODO: Find a more consistent way for both back- and front-end to access styling without needing this.
    if str.to_s.length > 0
      unless html_safe
        str = HTMLEntities.new.encode(str)
      end
      str = str.gsub(/\n/,"<br/>")
      str = str.gsub(/\[b\](.*?)\[\/b\]/m,'<strong>\1</strong>')
      str = str.gsub(/\[c\](.*?)\[\/c\]/m,'<div class="cos_code"><span class="jfdiCode cm-s-molokai ' << lang << 'Code">\1</span></div>')
      str = str.gsub(/\[mc\](.*?)\[\/mc\]/m){'<div class="cos_code"><pre><div class="jfdiCode cm-s-molokai ' << lang << 'Code">'<< $1.gsub(/<br>/,'
') <<'</div></pre></div>'}
      return str.html_safe
    end
    ""
  end

  def style_format(str, html_safe = true, lang='python')
    ApplicationHelper.style_format(str, html_safe, lang)
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
    direction = column == sort_column && sort_direction == "desc" ? "asc" : "desc"

    if css_class && sort_direction == "asc"
      icon = '<i class="icon-chevron-up"></i>'
    elsif css_class && sort_direction == 'desc'
      icon = '<i class="icon-chevron-down"></i>'
    else
      icon = ''
    end
    "<a href='#{url}?#{params}&sort=#{column}&direction=#{direction}' >#{title} #{icon}</a>".html_safe
  end

  def distance_of_time(seconds)
    mm, ss = seconds.to_i.divmod(60)
    hh, mm = mm.divmod(60)
    dd, hh = hh.divmod(24)

    "#{dd} d #{"%02d" % hh}:#{"%02d" % mm}:#{"%02d" % ss}"
  end

  def logged_out
    @facebook_uid ||= Koala::Facebook::OAuth.new(Facebook::APP_ID.to_s, Facebook::SECRET.to_s).get_user_from_cookies(cookies)
    @user = User.where(:provider => "facebook", :uid => @facebook_uid).first
    #if @user
    # !@user.is_logged_in?
    #else
    #  true
    #end
    @user and !@user.is_logged_in?
  end

  def get_social_media_url(user_course)
    if  user_course.user.provider == "facebook" and user_course.user.uid
      "https://www.facebook.com/#{user_course.user.uid}"
    else
      user_course.get_path
    end
  end
end
