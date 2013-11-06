$(function(){
  function append_query(href, attr) {
      if (href.indexOf('?') < 0) {
          return href + '?' + attr;
      } else {
          return href + '&' + attr
      }

  }
  $('.post-count-link').click(
      function() {
          var that = this;
          if (! $(that).data('loaded')) {
              $.ajax({
                  url: append_query($(that).attr('href'), 'raw=1'),
                  cache: false,
                  success: function(html){
                      $(that).closest('tr').next().find('.post-details').html(html);
                      $(that).data('loaded', true);
                  }
              });
          }
          $(that).closest('tr').next().fadeToggle();
          return false; // no link
      }
  )
})



