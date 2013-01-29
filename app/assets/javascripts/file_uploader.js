$(document).ready(function(){
  // setup the drag drop zone
  var target_el = '';

  $('.file-uploader-trigger').click(function() {
    target_el = $(this).attr('data-target');
    var modal = $(this).attr('href');
    $(modal).modal('show');
    return false;
  });

  // setup fileuploader
  $('#file-upload-form').fileupload({
    acceptFileTypes: '/(\.|\/)(zip)$/i',
    autoUpload: true,
    dropZone: $('#dropzone'),
    dataType: 'json',
    url: $('#file-upload-form').attr('action'),
    formData: [ { name: '_method',
                  value: 'POST ' } ],
    done: function(e, data) {
      console.log(data.result);
      console.log(target_el);
      $(target_el + '-input').attr('value', data.result.url);
      $(target_el + '-done').css('display', 'block');
      $('.file-uploader-insert-btn').click();
    }
  });

  // animation on the drop zone
  $(document).bind('dragover', function (e) {
      var dropZone = $('#dropzone'),
          timeout = window.dropZoneTimeout;
      if (!timeout) {
          dropZone.addClass('in');
      } else {
          clearTimeout(timeout);
      }
      if (e.target === dropZone[0]) {
          dropZone.addClass('hover');
      } else {
          dropZone.removeClass('hover');
      }
      window.dropZoneTimeout = setTimeout(function () {
          window.dropZoneTimeout = null;
          dropZone.removeClass('in hover');
      }, 100);
  });

  $(document).bind('drop dragover', function (e) {
    e.preventDefault();
  });
});
