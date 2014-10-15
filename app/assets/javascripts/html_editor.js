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


  wysi.commands.insertYoutube = {
    exec: function(composer, command, values) {
      /* eg. 
        value = {
          "videoUrl": "https://www.youtube.com/watch?v=80u2RixDLyk",
          "height": "123",
          "width": "234",
          "start": "0:30",
          "end": "1:22",
        };
      */

      if (!values || typeof values.videoUrl === "undefined") {
        return false;
      }

      var vidURL = values.videoUrl,
          vidID;
      if ( vidURL.substr(0,31) == 'http://www.youtube.com/watch?v=' ) {
        vidID = vidURL.substr(31).split('&')[0];
      } else if ( vidURL.substr(0,32) == 'https://www.youtube.com/watch?v=' ){
        vidID = vidURL.substr(32).split('&')[0];
      } else {
        //errorSpan.show();
        //alert("error");
        return false;
      }

      var doc     = composer.doc,
          textNode;
      var NODE_NAME = "IFRAME";

      var video = doc.createElement(NODE_NAME);
      var source = "http://www.youtube.com/embed/" + vidID
      var defaults = {
        "height": 315,
        "width": 420,
      };

      
      var hhmmss_to_s = function (hhmmss) {
        // Helper to convert from hh:mm:ss to seconds. e.g. 1:22 --> 82
        //disallow 0 as a start or end time. Use it as a sentinel value
        if (hhmmss == "") {
          return 0;
        }

        var tokens = hhmmss.split(':');
        var tok = parseInt(tokens[0]);
        var s;
        if (tokens.length < 2 || isNaN(tok) || tok > 59 || tok < 0) {
          return 0;
        } else {
          s = tok;
        }
        for (var i = 1; i < tokens.length; i++) {
          tok = parseInt(tokens[i]);
          if (isNaN(tok)) {
            return 0;
          } else {
            s = (s * 60) + tok;
          }
        }
        return s;
      };
      var start = hhmmss_to_s(values.start);
      var end = hhmmss_to_s(values.end);


      if ((start != 0) && (end != 0)) {
        source += "?start=" + start + "&end=" + end;
      } else if (start != 0) {
        source += "?start=" + start;
      } else if (end != 0) {
        source += "?end=" + end;
      }

      video.setAttribute("src", source);
      video.setAttribute("src2", source);
      video.setAttribute("frameborder", "0");
      if ((values.height !== "") && (values.width !== "")) {
        video.setAttribute("width", Math.max(values["width"], 250));
        video.setAttribute("height", Math.max(values["height"], 150));
      } else {
        video.setAttribute("width", defaults["width"]);
        video.setAttribute("height", defaults["height"]);
      }

      composer.selection.insertNode(video);
      if (wysihtml5.browser.hasProblemsSettingCaretAfterImg()) {
        textNode = doc.createTextNode(wysihtml5.INVISIBLE_SPACE);
        composer.selection.insertNode(textNode);
        composer.selection.setAfter(textNode);
      } else {
        composer.selection.setAfter(video);
      }
    },
    state: function(composer) {
      // Disallow selecting of video iframes
      return false;
    }
  };

})(wysihtml5);

$(document).ready(function() {
  // setup html editor
  var options = $.extend(true, {}, $.fn.wysihtml5.defaultOptions);
  options.parserRules.classes['coursemology-code'] = 1;
  options.parserRules.tags.sub = 1;
  options.parserRules.tags.sup = 1;
  options.parserRules.tags.iframe = {
    "check_attributes": {
      "width": "numbers",
      "alt": "alt",
      "src": "url",
      "src2": "url",
      "height": "numbers",
    },
    "set_attributes": {
      "frameborder": "0",
    }
  };

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

  // image upload button
  var imageUploadHtml = $('#html-editor-image-upload-tab').html();
  if (imageUploadHtml) {
    options.customTemplates = { 
      image: function(locale) {
        return imageUploadHtml;
      }
    };
  } else {
      options.customTemplates = {
          image: function(locale) {
              return false;
          }
      };
  }

  // insert youtube button
  var youtubeUploadHtml = $('#html-editor-insert-youtube-tab').html();
  if (youtubeUploadHtml) {
    options.toolbar.youtube = youtubeUploadHtml;
  }

  options.html = true;
  options.youtube = true;

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

  var exec_insert_youtube = function() {

    var youtubeUrl = $("#html-editor-youtube-url").val(),
        start = $("#html-editor-youtube-start").val(),
        end = $("#html-editor-youtube-end").val(),
        size = $("#html-editor-youtube-size").val(),
        sizes = {
          "sm": {
            "height": 150,
            "width": 250
          },
          "med": {
            "height": 315,
            "width": 420
          },
          "lg": {
            "height": 360,
            "width": 480
          },
        },
        hw = sizes[size];

    if (!hw) {
      hw = sizes["med"];
    }

    editor.currentView.element.focus();
    editor.composer.commands.exec('insertYoutube', {
      "videoUrl": youtubeUrl,
      "start": start,
      "end": end,
      "height": hw.height,
      "width": hw.width,
    });
  };

  $(document).on('DOMNodeInserted', function(e) {
    $('textarea.html-editor', e.target).each(handler);

    // Add hook to insert youtube button
    // 'off' prevents button from inserting twice, since component has to be re-initialised.
    $('#insert-youtube-button', e.target).off('click', exec_insert_youtube ); 
    $('#insert-youtube-button', e.target).on('click', exec_insert_youtube );
  });

  // This is a workaround for webkit's XSS measures.
  // http://stackoverflow.com/questions/6838172/embedded-video-not-rendering-in-chrome-on-first-load-after-embed-code-is-saved-t?lq=1
  if ($.browser.webkit) {
    $("iframe").each(function(){
        $(this).attr('src', $(this).attr('src2'));
    });
  };
});
