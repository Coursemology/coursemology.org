// wysihtml5 <code> tag component for code.
// https://github.com/xing/wysihtml5/issues/43
(function(wysihtml5) {
  "use strict";
  var NODE_NAME = 'CODE';

  wysihtml5.commands.createCode = {
    exec: function(composer, command) {
      var selection = composer.selection.getSelectedNode();
      var result = wysihtml5.commands.formatInline.exec(composer, command, 'code');

      // Make sure we do not have new <code> blocks split by <br />'s
      $('br', selection).each(function(n, elem) {
        var $elem = $(elem);
        var $prev = $elem.prev();
        var $next = $elem.next();

        var $next_children = $next.contents();
        $next_children.detach();
        $prev.append(elem);
        $next_children.appendTo($prev);
        $next.remove();
      });
      $('code', selection).addClass('jfdiCode');
      return result;
    },

    state: function(composer, command) {
      // element.ownerDocument.queryCommandState("bold") results:
      // firefox: only <b>
      // chrome: <b>, <strong>, <h1>, <h2>, ...
      // ie: <b>, <strong>
      // opera: <b>, <strong>
      return wysihtml5.commands.formatInline.state(composer, command, 'code');
    }
  };
})(wysihtml5);

$(document).ready(function() {
  // setup html editor
  var imgUploadHtml = $('#html-editor-image-upload-tab').html();
  var options = $.extend(true, {}, $.fn.wysihtml5.defaultOptions);
  options.toolbar = {
    code: '<li>' +
            '<div class="btn-group">' +
            '<a class="btn" data-wysihtml5-command="createCode" title="Insert Code" tabindex="-1"><i class="icon-wrench"></i></a>' +
            '</div>' +
          '</li>'
  };
  options.parserRules.classes['jfdiCode'] = 1;

  if (imgUploadHtml) {
    options.html = true;
    options.customTemplates = {
      image: function(locale) {
        return imgUploadHtml;
      }
    };
  }

  var handler = function() {
    var $this = $(this);
    if ($this.data('wysihtml5')) {
      // We need to reinitialise the component; otherwise the iframe is as good as dead
      // see https://github.com/xing/wysihtml5/issues/148
      $this.css('display', 'block');
      var input = $this.val();
      $this.siblings('.wysihtml5-sandbox, .wysihtml5-toolbar, input[name="_wysihtml5_mode"]').remove();
    }

    $(this).wysihtml5(options);
  };

  $(document).on('DOMNodeInserted', function(e) {
    $('textarea.html-editor', e.target).each(handler);
  });
});
