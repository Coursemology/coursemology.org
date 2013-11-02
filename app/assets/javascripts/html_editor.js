$(document).ready(function() {
  // setup html editor
  var imgUploadHtml = $('#html-editor-image-upload-tab').html();
  var handler;

  if (imgUploadHtml) {
    var options = {
        "html": true,
      customTemplates: {
        image: function(locale) {
          return imgUploadHtml;
        }
      }
    };
    handler = function() { $(this).wysihtml5(options); };
  } else {
    handler = function() { $(this).wysihtml5(); };
  }

  $(document).on('DOMNodeInserted', function(e) {
      $('textarea.html-editor', e.target).each(handler);
  })
});
