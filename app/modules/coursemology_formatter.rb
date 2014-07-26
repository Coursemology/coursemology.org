class CoursemologyFormatter
  def self.format(text)
    '<p>' + sanitize(text) + '</p>'
  end

  def self.sanitize(text)
    whitelist = {
      :elements => %w[
        a abbr b bdo blockquote br caption cite code col colgroup dd del dfn div dl
        dt em figcaption figure h1 h2 h3 h4 h5 h6 hgroup i img ins kbd li mark
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
end
