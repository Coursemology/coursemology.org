forum = {};
function forumToggleLike(post_id) {
    var e = $('.like-'+post_id);
    var c = $('.like-count-'+post_id);
    if (e.hasClass('active')) {
        $.ajax({
            url: (forum.topicPath+"/posts/"+post_id+"/unlike")
        }).done(function(){
            e.text('Like');
            c.text(parseInt(c.text())-1);
        })
    } else {
        $.ajax({
            url: (forum.topicPath+"/posts/"+post_id+"/like")
        }).done(function(){
            e.text('Unlike');
            c.text(parseInt(c.text())+1);
        })
    }
}