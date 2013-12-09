$(document).ready(function() {
  "use strict";
  $('.forum .btn.reply').click(function(e) {
    // Set the post we are replying to.
    var post_id = parseInt($(this).data('postId'));
    var $quick_reply = $('.forum .quick-reply');
    $('#forum_post_parent_id', $quick_reply).val(post_id);

    // Reattach the form beneath the post we are replying to.
    var $post = $('.forum div#post-' + post_id);
    $quick_reply.hide();
    $quick_reply.detach();
    $quick_reply.appendTo($('div.contents', $post));
    $quick_reply.slideDown();

    $('html, body').animate({
      scrollTop: $quick_reply.offset().top
    }, 500);

    e.preventDefault();
  })
});
