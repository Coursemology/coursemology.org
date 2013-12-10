// Inspired by the implementation upstream in https://github.com/evereq/bootstrap-wysihtml5
// that has not made it to the Rails version.
(function(wysi) {
  "use strict";

  function exec(composer) {

    var pre = this.state(composer);

    if (pre) {
      // caret is already within a <pre><code>...</code></pre>
      composer.selection.executeAndRestore(function () {
        var codeSelector = pre.querySelector("code");
        wysi.dom.replaceWithChildNodes(pre);
        if (codeSelector) {
          wysi.dom.replaceWithChildNodes(pre);
          hljs.highlightBlock(pre);
        }
      });
    } else {
      // Wrap in <pre><code class="jfdiCode">...</code></pre>
      var range = composer.selection.getRange();
      if (!range) {
        return false;
      }

      var selectedNodes = range.extractContents(),
          preElem = composer.doc.createElement("pre"),
          code = composer.doc.createElement("code");

      preElem.appendChild(code);
      code.appendChild(selectedNodes);
      code.className = 'jfdiCode';
      range.insertNode(preElem);
      hljs.highlightBlock(preElem);
      composer.selection.selectNode(preElem);
    }
  }

  function state(composer) {
    var selectedNode = composer.selection.getSelectedNode();
    return wysi.dom.getParentElement(selectedNode, { nodeName: "CODE" }) &&
      wysi.dom.getParentElement(selectedNode, { nodeName: "PRE" });
  }

  wysi.commands.createCode = {
    exec: exec,
    state: state
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
