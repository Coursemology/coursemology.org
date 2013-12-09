$(document).ready(function() {
  "use strict";
  $('.forum .btn.reply').click(function(e) {
    // Set the post we are replying to.
    var $quick_reply = $('.forum .quick-reply');
    $('#forum_post_parent_id', $quick_reply).val($(this).data('postId'));

    // Reattach the form beneath the post we are replying to.
    $quick_reply.hide();
    $quick_reply.detach();
    $quick_reply.appendTo($(this).parents('div.contents'));
    $quick_reply.slideDown();

    e.preventDefault();
  })
});
