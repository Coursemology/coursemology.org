$(document).ready(function(){
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

  // setup fileuploader
  $('#file-upload-form').fileupload({
    acceptFileTypes: '/(\.|\/)(gif|jpe?g|png)$/i',
    autoUpload: true,
    dropZone: $('#dropzone'),
    dataType: 'json',
    url: $('#file-upload-form').attr('action'),
    done: function(e, data) {
      console.log(data.result);
      $('.image-uploader-input-url').val(data.result.url);
      $('.image-uploader-preview-img').attr('src', data.result.url);
      $('.image-uploader-insert-btn').click();
    }
  });
});
