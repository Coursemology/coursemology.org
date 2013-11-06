$(function(){
  $('.post-count-link').click(
      function() {
          var that = this;
          if (! $(that).data('loaded')) {
              $.ajax({
                  url: $(that).attr('href') + '&raw=1',
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



