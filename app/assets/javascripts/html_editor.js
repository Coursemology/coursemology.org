$(document).ready(function() {
  // setup html editor
  var imgUploadHtml = $('#html-editor-image-upload-tab').html();

  if (imgUploadHtml) {
    var options = {
        "html": true,
      customTemplates: {
        image: function(locale) {
          return imgUploadHtml;
        }
      }
    };
    $('textarea.html-editor').wysihtml5(options);
  } else {
    $("textarea.html-editor").each(function(){$(this).wysihtml5();});
  }
});
