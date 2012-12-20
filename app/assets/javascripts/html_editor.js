$(document).ready(function() {
  // setup html editor
  var imgUploadHtml = $('#image-upload-tab').html();
  var options = {
    customTemplates: {
      image: function(locale) {
        return imgUploadHtml;
      }
    }
  };

  $('textarea.html-editor').wysihtml5(options);

  // setup fileuploader
  $('#file-upload-form').fileupload({
    acceptFileTypes: '/(\.|\/)(gif|jpe?g|png)$/i',
    autoUpload: true,
    dropZone: $('#dropzone'),
    dataType: 'json',
    url: $('#file-upload-form').attr('action'),
    done: function(e, data) {
      console.log(data.result);
      $(this).find('.bootstrap-wysihtml5-insert-image-url').val(data.result.url);
      $('.bootstrap-wysihtml5-insert-image-modal').find('.insert-btn').click();
    }
  });

  // setup the drag drop zone
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
