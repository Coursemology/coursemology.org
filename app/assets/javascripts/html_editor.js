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
})(wysihtml5);




$(document).ready(function() {
  // setup html editor
  // the buttons have been modified so that they work with Bootstrap 2.
  
  var options = $.extend(true, {}, $.fn.wysihtml5.defaultOptions);
  options.customTemplates = {};
  options.parserRules.classes['coursemology-code'] = 1;

  // image upload button
  var imgUploadHtml = $('#html-editor-image-upload-tab').html();
  if (imgUploadHtml) {
    options.customTemplates = {
      image: function(locale) {
        return imgUploadHtml;
      }
    };
  }

  // link button
  var modifiedLinkTemplate = function(locale) {
      return "<li>" +
          '<div class="bootstrap-wysihtml5-insert-link-modal modal fade"> \
              <div class="modal-dialog ">  \
                <div class="modal-content">  \
                  <div class="modal-header">   \
                    <a class="close" data-dismiss="modal">×</a>\
                    <h3>Insert link</h3>\
                  </div>\
                  <div class="modal-body">\
                    <input value="http://" class="bootstrap-wysihtml5-insert-link-url form-control">\
                    <label class="checkbox"> <input class="bootstrap-wysihtml5-insert-link-target" checked="" type="checkbox">Open link in new window</label>\
                  </div>\
                  <div class="modal-footer">\
                    <a class="btn btn-default" data-dismiss="modal">Cancel</a>\
                    <a href="#" class="btn btn-primary" data-dismiss="modal">Insert link</a>\
                  </div>\
                </div>\
              </div>\
            </div>' +
             "<a class='btn btn-default' data-wysihtml5-command='createLink' title='Insert Link' tabindex='-1'><i class='icon-link'></i></a>" + 
             "</li>";
  };
  options.customTemplates.link = modifiedLinkTemplate;
  
  // blockquote button
  var modifiedQuoteTemplate = function(locale) {
      return "<li>" +
             "<div class='btn-group'>" +
             '<a class="btn  btn-default" data-wysihtml5-command="formatBlock" '+  //wysihtml5-command-active
             'data-wysihtml5-command-value="blockquote" data-wysihtml5-display-format-name="false" tabindex="-1">'+
             "<i class='icon-quote-right'></i></a>" +
             "</div>" +
             "</li>";
  };
  options.customTemplates.blockquote = modifiedQuoteTemplate;

  // lists buttons
  var modifiedListTemplate = function(locale) {
      return "<li>" +
             "<div class='btn-group'>" +
             "<a class='btn' data-wysihtml5-command='insertUnorderedList' title='Unordered List'><i class='icon-list'></i></a>" +
             "<a class='btn' data-wysihtml5-command='insertOrderedList' title='Ordered Lists'><i class='icon-th-list'></i></a>" +
             "<a class='btn' data-wysihtml5-command='Outdent' title='Outdent'><i class='icon-indent-left'></i></a>" +
             "<a class='btn' data-wysihtml5-command='Indent' title='Indent'><i class='icon-indent-right'></i></a>" +
             "</div>" +
             "</li>";
  };
  options.customTemplates.lists = modifiedListTemplate;

  // html toggle
  var modifiedHtmlTemplate = function(locale) {
      return "<li>" +
             "<div class='btn-group'>" +
             "<a class='btn  btn-default' data-wysihtml5-action='change_view' title='Edit Html'><i class='icon-pencil'></i></a>" +
             "</div>" +
             "</li>";
  };
  options.customTemplates.html = modifiedHtmlTemplate;
  
  // code button
  var codeButtonTemplate = function(locale) {
    return '<li>' +
            '<div class="btn-group">' +
            '<a class="btn" data-wysihtml5-command="createCode" title="Insert Code" tabindex="-1"><i class="icon-wrench"></i></a>' +
            '</div>' +
            '</li>';
  };
  options.customTemplates.code = codeButtonTemplate;


  options.toolbar = {
    "font-styles": true, //Font styling, e.g. h1, h2, etc. Default true
    "emphasis": true, //Italics, bold, etc. Default true
    "lists": true, //(Un)ordered lists, e.g. Bullets, Numbers. Default true
    "html": true, //Button which allows you to edit the generated HTML. Default false
    "link": true, //Button to insert a link. Default true
    "image": true, //Button to insert an image. Default true,
    "color": false, //Button to change color of font  
    "blockquote": true, //Blockquote  
    //"size": <buttonsize> //default: none, other options are xs, sm, lg
    "code": true
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
