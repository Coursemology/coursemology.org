module ComicsHelper
  def comic_link_text(comic)
    comic.episode.to_s + '. ' + comic.name + (comic.visible ? '' : ' (hidden)')
  end
end

