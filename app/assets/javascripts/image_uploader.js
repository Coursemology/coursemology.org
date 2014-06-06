$(document).ready(function() {
  "use strict";
  // setup the drag drop zone
  var target_el = '';

  var showError = function(message) {
    var $alert = $('.alert');
    $alert.removeClass('hidden');
    $alert.html("Error uploading image: " + message);
  };

  $('.image-uploader-trigger').click(function() {
    target_el = $(this).attr('data-target');
    var modal = $(this).attr('href');
    $(modal).modal('show');
    return false;
  });

  $(document).on('dragover', function (e) {
    var $this = $(this),
        $dropZone = $this.find('#image-uploader-modal #image-dropzone'),
        timeout = window.dropZoneTimeout;

    if (!timeout) {
      $dropZone.addClass('in');
    } else {
      clearTimeout(timeout);
    }

    if ($(e.target).is($dropZone)) {
      $dropZone.addClass('hover');
    } else {
      $dropZone.removeClass('hover');
    }

    window.dropZoneTimeout = setTimeout(function () {
      window.dropZoneTimeout = null;
      $dropZone.removeClass('in hover');
    }, 100);
  });

  $(document).bind('drop dragover', function (e) {
    e.preventDefault();
  });

  // setup fileuploader
  $(document).on('DOMNodeInserted', function(e) {
    $('#image-upload-form', e.target).fileupload({
      maxFileSize: 5000000,
      acceptFileTypes: '/(\.|\/)(gif|jpe?g|png)$/i',
      autoUpload: true,
      dropZone: $('#image-uploader-modal #image-dropzone'),
      dataType: 'json',
      url: $('#image-upload-form').attr('data-url'),
      formData: [
        {
          name: '_method',
          value: 'POST '
        }
      ],

      add: function(e, data) {
        // the jquery-fileupload-rails gem doesn't include the validation
        // scripts, we have to do the check manually. >_<

        var file = data.files[0],
            that = $(this).data('blueimp-fileupload') || $(this).data('fileupload'),
            options = that.options,
            $modal = $('.modal'),
            fileSize;

        if (options.maxFileSize) {
          fileSize = file.size;
        }

        if ($.type(fileSize) === 'number' &&
            fileSize > options.maxFileSize) {
          showError("File is too large");
          $modal.modal('hide');
        } else if (options.acceptFileTypes &&
            !(options.acceptFileTypes.test(file.type) ||
            options.acceptFileTypes.test(file.name))) {
          showError("Unaccepted file type");
          $modal.modal('hide');
        } else {
          data.submit();
        }
      },

      progress: function(e, data) {
        var progress = parseInt(data.loaded / data.total * 100, 10),
            $bar = $(this).find('.bar'),
            progress_percent = progress + '%';

        $bar.width(progress_percent);
        $bar.html(progress_percent);
      },

      done: function(e, data) {
        $('.image-uploader-input-url').val(data.result.url);
        $('.image-uploader-preview-img').attr('src', data.result.url);
        $(target_el + '-preview').attr('src', data.result.url);
        $(target_el + '-input').attr('value', data.result.url);
      },

      fail: function(e, data) {
        showError(data.errorThrown);
      },

      always: function(e, data) {
        var $bar = $(this).find('.bar');
        $bar.width(0);
        $bar.html('');
        // dismiss modal upon success, abort or error. ie. always
        $('.image-uploader-insert-btn').click();
      }
    });
  });
});
