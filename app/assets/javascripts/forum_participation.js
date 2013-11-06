$(function(){
  $('.post-count-link').click(
      function() {
          var that = this;
          if ($(that).data('loaded')) {
              $(that).closest('tr').next().find('.post-details').fadeToggle();
          } else {
              $.ajax({
                  url: $(that).attr('href') + '&raw=1',
                  cache: false,
                  success: function(html){
                      $(that).closest('tr').next().find('.post-details').html(html).fadeIn();
                      $(that).data('loaded', true);
                  }
              });

          }
          return false; // no link
      }
  )
})



