forum = {};
function forumToggleLike(post_id) {
    var e = $('.like-'+post_id);
    var c = $('.like-count-'+post_id);
    if (e.hasClass('active')) {
        $.ajax({
            url: (forum.topicPath+"/posts/"+post_id+"/unlike")
        }).done(function(){
            e.text('Like');
            var count = parseInt(c.text())-1;
            c.text(count);
            if (count > 0) {
                c.parent().show();
            } else {
                c.parent().hide();
            }
        })
    } else {
        $.ajax({
            url: (forum.topicPath+"/posts/"+post_id+"/like")
        }).done(function(){
            e.text('Unlike');
            var count = parseInt(c.text())+1;
            c.text(count);
            if (count > 0) {
                c.parent().show();
            } else {
                c.parent().hide();
            }
        })
    }
}