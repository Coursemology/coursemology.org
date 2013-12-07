$(document).ready(function() {
  "use strict";
  $('#topic .btn.reply').click(function(e) {
    $('#topic #forum_post_parent_id').val($(this).data('postId'));
    e.preventDefault();
  })
});
