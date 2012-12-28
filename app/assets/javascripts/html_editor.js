$(document).ready(function() {
  // setup html editor
  var imgUploadHtml = $('#html-editor-image-upload-tab').html();

  var options = {
    customTemplates: {
      image: function(locale) {
        return imgUploadHtml;
      }
    }
  };

  $('textarea.html-editor').wysihtml5(options);
});
