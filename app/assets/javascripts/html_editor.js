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
        }
      });
    } else {
      // Wrap in <code class="coursemology-code">...</code>
      var range = composer.selection.getRange();
      if (!range) {
        return false;
      }

      var selectedNodes = range.extractContents(),
          code = composer.doc.createElement("code");

      code.appendChild(selectedNodes);
      code.className = 'coursemology-code';
      range.insertNode(code);
      composer.selection.selectNode(code);
    }
  }

  function state(composer) {
    var selectedNode = composer.selection.getSelectedNode();
    return wysi.dom.getParentElement(selectedNode, { nodeName: "CODE" });
  }

  wysi.commands.createCode = {
    exec: exec,
    state: state
  };

  wysi.commands.sup = {
    exec: function(composer, command) {
      return wysihtml5.commands.formatInline.exec(composer, command, "sup");
    },
    state: function(composer, command) {
      return wysihtml5.commands.formatInline.state(composer, command, "sup");
    }
  };

  wysi.commands.sub = {
    exec: function(composer, command) {
      return wysihtml5.commands.formatInline.exec(composer, command, "sub");
    },
    state: function(composer, command) {
      return wysihtml5.commands.formatInline.state(composer, command, "sub");
    }
  };

})(wysihtml5);

$(document).ready(function() {
  // setup html editor
  var imgUploadHtml = $('#html-editor-image-upload-tab').html();

  var options = $.extend(true, {}, $.fn.wysihtml5.defaultOptions);
  options.parserRules.classes['coursemology-code'] = 1;
  options.customTemplates = {};

  if (imgUploadHtml) {
    options.customTemplates = {
      image: function(locale) {
        return imgUploadHtml;
      }
    };
  }

  options.toolbar = {
    // code font button
      code: '<li>' +
            '<div class="btn-group">' +
            '<a class="btn" data-wysihtml5-command="createCode" title="Insert Code" tabindex="-1"><i class="icon-wrench"></i></a>' +
            '</div>' +
            '</li>',

    // superscript and subscript button
    subSup: '<li>' +
            '<div class="btn-group">' +
            '<a class="btn btn-default" data-wysihtml5-command="sup" title="Superscript" tabindex="-1">x<sup>2</sup></a>' +
            '<a class="btn btn-default" data-wysihtml5-command="sub" title="Subscript" tabindex="-1">x<sub>2</sub></a>' +
            '</div>' +
            '</li>',
  };

  options.html = true;

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
