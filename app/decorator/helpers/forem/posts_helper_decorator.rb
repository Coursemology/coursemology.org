Forem::PostsHelper.class_eval do
  def quote_reply(post)
    short_quote = truncate_html Forem.formatter.format(post.text), length: 500, omission: '...'
    attribution = post.user.name + ' wrote at ' + datetime_no_seconds(post.created_at) + ':<br/>'
    quote = '<blockquote><i>' + short_quote + '</i></blockquote><br/><br/>'
    attribution + quote
  end
end