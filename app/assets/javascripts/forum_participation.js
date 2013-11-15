$(function(){
  function append_query(href, attr) {
      if (href.indexOf('?') < 0) {
          return href + '?' + attr;
      } else {
          return href + '&' + attr
      }

  }
  $('.view-post-btn').click(
      function() {
          var that = this;
          if (! $(that).data('loaded')) {
              $.ajax({
                  url: append_query($(that).closest('tr').find('.post-count-link').attr('href'), 'raw=1&limit=10'),
                  cache: false,
                  success: function(html){
                      $(that).closest('tr').next().find('.post-details').html(html);
                      $(that).data('loaded', true);
                  }
              });
          }

          // hide all other containers and mark the button as not opened
          $container = $(that).closest('tr').next();
          $('.post-details-container').not($container).hide();
          $('.view-post-btn').not(this).data('opened', false).text('View');

          // toggles the corresponding container
          $container.fadeToggle();

          // toggles the current button's opened value
          if ($(this).data('opened')) {
              $(this).data('opened', false).text('View');
          } else {
              $(this).data('opened', true).text('Hide');
              // scrollTop only if it is to open the container

              var offset = $(this).offset().top - 50; // offset for nav bar

              $('html, body').animate({
                  scrollTop: offset
              }, 200);
          }


      }
  )
})



