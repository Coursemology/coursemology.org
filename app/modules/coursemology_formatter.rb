class CoursemologyFormatter

  def self.format(text)
    '<p>' + sanitize(text) + '</p>'
  end

  def self.sanitize(text)
    whitelist = {
      :elements => %w[
        a abbr b bdo blockquote br caption cite code col colgroup dd del dfn div dl
        dt em figcaption figure h1 h2 h3 h4 h5 h6 hgroup i iframe img ins kbd li mark
        ol p pre q rp rt ruby s samp small strike strong sub sup table tbody td
        tfoot th thead time tr u ul var wbr
      ],

      :attributes => {
          :all         => ['dir', 'lang', 'title'],
          'a'          => ['href', 'target'],
          'blockquote' => ['cite'],
          'code'       => ['class'],
          'col'        => ['span', 'width'],
          'colgroup'   => ['span', 'width'],
          'del'        => ['cite', 'datetime'],
          'iframe'     => ['align', 'alt', 'frameborder', 'height', 'src', 'src2', 'width',
                           'allowfullscreen', 'mozallowfullscreen', 'webkitallowfullscreen'],
          'img'        => ['align', 'alt', 'height', 'src', 'width'],
          'ins'        => ['cite', 'datetime'],
          'ol'         => ['start', 'reversed', 'type'],
          'q'          => ['cite'],
          'table'      => ['summary', 'width'],
          'td'         => ['abbr', 'axis', 'colspan', 'rowspan', 'width'],
          'th'         => ['abbr', 'axis', 'colspan', 'rowspan', 'scope', 'width'],
          'time'       => ['datetime', 'pubdate'],
          'ul'         => ['type']
      },

      :protocols => {
          'a'          => {'href' => ['ftp', 'http', 'https', 'mailto', :relative]},
          'blockquote' => {'cite' => ['http', 'https', :relative]},
          'del'        => {'cite' => ['http', 'https', :relative]},
          'iframe'     => {'src'  => ['http', 'https', :relative],
                           'src2' => ['http', 'https', :relative]},
          'img'        => {'src'  => ['http', 'https', :relative]},
          'ins'        => {'cite' => ['http', 'https', :relative]},
          'q'          => {'cite' => ['http', 'https', :relative]}
      },
      :add_attributes => {
          'a' => {'rel' => 'nofollow'}
      }
    }
    Sanitize.clean(text, whitelist)
  end

  def self.clean_code_block(description)
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
    result
  end

  def self.style_format(str, html_safe = false, lang='python')
    # TODO: Find a more consistent way for both back- and front-end to access styling without needing this.
    if str.to_s.length > 0
      unless html_safe
        str = self.sanitize(str)
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
end
