/**
 * Created with JetBrains RubyMine.
 * User: Raymond
 * Date: 23/7/13
 * Time: 2:26 PM
 * To change this template use File | Settings | File Templates.
 */

//code from JFDI acedamy
CodeViewer = {};

CodeViewer.init = function($wrapper, source, theme, code_id, edit){


    function setUpLines(){
        var $lines = $output.find("div.lines");
        var i = 1;

        function box_mdown(e){
            e.stopPropagation();
            if ($(this).hasClass('annotate')){
                $(this).data('lh').eq(0).click();
            }else if (end_line == $(this).data('l')){
                start = this;
                start_line = $(this).data('l');
            }
            return false;
        }
        function box_over(){
            end = this;
            el = $(this).data('l');
            if (!start) start_line = el;
            var s = (start_line < el) ? start_line : el;
            var e = (start_line > el) ? start_line : el;

            for (var i=0;i<_comments.length;++i){
                if (_comments[i].s >= s && _comments[i].s <= e) return false;
                if (_comments[i].s <= s && _comments[i].s >= e) return false;
                if (_comments[i].e >= s && _comments[i].e <= e) return false;
                if (_comments[i].e <= s && _comments[i].e >= e) return false;
                if (_comments[i].s <= s && _comments[i].e >= e) return false;
            }

            end_line = $(this).data('l');
            s = (start_line < end_line) ? start_line : end_line;
            e = (start_line > end_line) ? start_line : end_line;
            if (start){ // dragging in action
                $_line_numbers.removeClass('hover').slice(s,e+1).addClass('hover');
                $_lines.removeClass('highlight').slice(s,e+1).addClass('highlight');
            }
            $(this).addClass('hover');
        }
        function box_out(){
            if (!start){
                $(this).removeClass('hover');
                $_lines.removeClass('highlight');
            }
        }
        function box_up(){
            if (start){
                var s = (start_line < end_line) ? start_line : end_line;
                var e = (start_line > end_line) ? start_line : end_line;
                $_line_numbers.removeClass('hover');
                createComment(s+1, e+1,false, true);
                if (hideAnnotate) showAnnotation();
                start = false;
            }
        }


        $_lines = $output.find('pre.line');
        $_lines.each( function() {
            line_obj.push( this );
            var $l = $('<div class="line-number">'+i+'</div>');
            $l.css('height', $(this).height() + 'px')
                .css('line-height',($(this).height() +3)+ 'px')
                .css('top', ($(this).offset().top -topOffset)+ 'px')
                .data('l',i-1)
                .appendTo($lines);
            ++i;
        });
//		if (_ca){
        $_line_numbers = $('.line-number')
            .bind('mousedown', box_mdown)
            .hover(box_over, box_out)
        $(document).bind('mouseup',box_up);
//		}
    }
    function addAnnotateBox(){
        if (!_ca) return false;
        $("#annotate-area").remove();

        $ab = $('<div id="annotate-area"></div>')
        $ab.append('<p class="annotate-message">Leave an annotation:</p>');
        $ta = $('<textarea class="annotate-box" id="annotate-box"></textarea>')
            .data('s', start_line+1).data('e', end_line+1)
            .appendTo($ab);
        $ab.append('<button class="btn" id="annotateButton">Annotate</button>');
        this.append($ab);

        $ta.focus();
        $("#annotateButton").on('click',function(){
            var $ab = $("#annotate-box");
            if ($ab.attr('disabled') == 'disabled') return false;
            var t = $ab.val().trim();
            var s = $ab.data('s'), e = $ab.data('e');
            if (t == ''){
                $ab.focus();
            }else{
                $ab.attr('disabled','disabled');
                $.post($('#annotation_path').val(), {
                    origin: document.URL,
                    annotation:{
                        annotable_id: _cid,
                        annotable_type: "StdCodingAnswer",
                        text: t,
                        line_start: s,
                        line_end: e
                    }}, function(s){
                    $ab.attr('disabled',false).val('');
                    parseComments(s);
                });
            }
        });
    }
    function createComment(start, end, callback, temporary) {
        if (_vt!='view')return;
        if ( ($tcb = $("#temporary-comment-box")) && $tcb.size()){
            if (start != $tcb.data('s') || end != $tcb.data('e')){
                removeComment.call( $('#temporary-comment-box') );
            }
        }

        temporary = (typeof temporary != 'undefined');

        if (typeof $_comment_boxes[start] != 'undefined'){
            $cb = $_comment_boxes[start];
        }else{

            var $lh = addLineHighlighter(start, end);
            var $cb = $('<div class="comment-box" '+(temporary ? 'id="temporary-comment-box"':'')+'/>');

            if (!line_obj[start-1])return false;
            $cb.appendTo(document.body);
            $cb
                .css('width', _cb_mw+'px')
                .css('top', ($(line_obj[start-1]).offset().top)+'px')
                .data('top', ($(line_obj[start-1]).offset().top) + $wrapper.scrollTop())
                .css('minHeight', (end-start+1)*$lh.height() + 'px')
                .data('s', start)
                .data('e', end);

            var $lines = setLinesHover(start, end, $lh, $cb);

            $_comment_boxes[start] = $cb;
            if (!temporary){
                _comments.push( {s: start-1, e: end-1} );
            }
        }

        if ($.isFunction(callback)) callback.call($cb);
        if (temporary){
            activateComment($cb);
        }
    }
    function removeComment(){
        if (this.size()){
            delete $_comment_boxes[ this.data('s')];
            removeLineHighlighter( this.data('s'), this.data('e') );
            this.remove();
            $active = false;
        }
    }
    function removeLineHighlighter(start, end){
        $_lines.slice(start-1, end).removeClass('annotate').unbind('mouseenter').unbind('mouesleave').unbind('click');
        $_line_numbers.slice(start-1, end).removeClass('annotate').data('lh', false);
    }
    function addLineHighlighter(start, end) {
        $lh = $_lines.slice(start-1, end).addClass('annotate');
        $_line_numbers.slice(start-1, end).addClass('annotate').data('lh', $lh);
        return $lh;
    }
    function setLinesHover(start, end, $lh, $cb) {
        var $lines = $_lines.slice(start-1, end);
        $lines
            .addClass('annotate-active')
            .bind('mouseenter', function() {
                $lh.addClass('hover');
                $cb.addClass('hover');
            })
            .bind('mouseleave', function() {
                $lh.removeClass('hover');
                $cb.removeClass('hover');
            })
            .click( function() {
                activateComment($cb);
            });
        return $lines;
    }
    var $active = false;
    function activateComment($com) {
        if (!$com.is('#temporary-comment-box')){
            removeComment.call( $('#temporary-comment-box') );
        }else if(($active && $active.is("#temporary-comment-box"))){
            removeComment.call( $('#temporary-comment-box') );
            $active = false;
            return false;
        }
        if ($active) {
            if ($active == $com){
                $active.animate({
                    'max-height': '100px'
                }, 'slow');
                $active.removeClass('active', 500);
                $active = false;
                $("#annotate-area").remove();
            }else{
                $active.animate({
                    'max-height': '100px'
                }, 'slow');
                $active.removeClass('active', 500);
                $com.css({
                    'max-height': 'none'
                });
                $com.addClass('active', 300);
                $active = $com;
            }
        } else {
            var contentHeight = $('.annotate-area', $com).outerHeight(true);

            $com.animate({
                'max-height': contentHeight + 1000
            }, 'slow');

            $com.addClass('active', 300);
            $active = $com;
        }

        if ($active == $com){
            start_line = $com.data('s')-1;
            end_line = $com.data('e')-1;
            addAnnotateBox.call($com);
        }
        checkScroll();
    }

    function checkScroll(evt) {
        if (hideAnnotate) return true;

        var st = $wrapper.scrollTop();
        $('.comment-box').each( function() {
            var $this = $(this);
            var ct = $this.data('top');
            ct -= st;
            if (fullScreenOffset) ct -= fullScreenOffset
            if (false && fullScreenOffset){
//				$this.css('top', ct+'px').show();
            }else{
                if (ct < topOffset || ct + 20 >= bottomOffset) {
                    if ($this.is('#temporary-comment-box')){
                        removeComment.call($this);
                    }else{
                        $this.fadeOut('fast');
                    }
                } else {
                    if (!$this.is(':visible')) {
                        $this.fadeIn('fast');
                    }
                    if (fullScreenOffset && ct + $this.height() > bottomOffset){
                        $this.css('top','auto').css('bottom',  '0px');
                    }else{
                        $this.css('bottom','auto').css('top', ct+'px');
                    }
                }
            }
        });
        return true;
    }
    function setUp() {
        $wrapper.bind("scroll", checkScroll);

        // check height
        if ($output.height() < $wrapper.height()){
            $wrapper.height($output.height()+'px');
        }
        // check width

        $output.width($wrapper.get(0).scrollWidth);

        // check annotation width
        var x = function(){
            var len = $(document).scroll().width() - $wrapper.offset().left - $wrapper.width();
            _cb_mw = len;
        }
        x();
    }

    function parseComments(annotations){
        if (typeof Comment != 'undefined'){
            Comment.parseComment(annotations, _cid);
        }
        for (var i=0;i<annotations.length;++i){
            if (typeof _annotate_ids[annotations[i].id] != 'undefined') continue;
            _annotate_ids[annotations[i].id] = true;
            if (annotations[i].s == -1){
            }else{
                createComment(annotations[i].s, annotations[i].e, function(){
                    if (this.is('#temporary-comment-box')){
                        this.attr('id', '');
                        _comments.push( {s: annotations[i].s-1, e: annotations[i].e-1} );
                    }
                    makeComment(annotations[i], this)
                });
            }
        }
        checkScroll.call($wrapper);
    }

    function del_annotation($li) {
        $obj = $li.find('.comment-obj');
        if(!confirm("TO DELETE: \n\n"+ $obj.attr('o') + "\n\nBY: " + $obj.attr('author') )) {
            return;
        }

        $.ajax({
                url:$("#annotation_path").val()+"/"+$obj.attr('cid'),
                type: "DELETE",
                dataType:"json",
                success: function(e) {
                    $li.hide('slow', function(){ $li.remove(); });
                }
            }
        )

    }

    function edit_annotation($li) {
        $edit = $li.find('.comment-edit-link');
        $del = $li.find('.comment-del-link');
        $obj = $li.find('.comment-obj');
        original = $obj.attr('o');
//        rendered = $obj.attr('c');
        id = $obj.attr('cid');
        var textarea = $li.find('.annotate-box');
        comment = $li.find('.comment');
        if(textarea.size() == 0) {
            //edit clicked
            textarea = $('<textarea class="annotate-box" style="margin-bottom: 9px; display: none" />');
            textarea.val(original);
            comment.empty().append(textarea);
            textarea.show('slow');
            $edit.empty().append('<i class="icon-ok"></i>');
            $del.empty().append('<i class="icon-remove"></i>');
            $del.unbind('click');
            $del.bind('click', (function(e) {
                e.preventDefault();
                quit_edit_annotation($li);
            }));
        } else {
            //save comment
            $.ajax({
                url:$("#annotation_path").val()+"/"+$obj.attr('cid'),
                type: "PUT",
                dataType:"json",
                data: {
                    text: textarea.val()
                },
                success: function(resp) {
                    $obj.attr('o', resp.o);
                    $obj.attr('c', resp.c);

                    quit_edit_annotation($li)
                }
            });
        }

    }

     function quit_edit_annotation($li) {
         $edit = $li.find('.comment-edit-link');
         $del = $li.find('.comment-del-link');
         var textarea = $li.find('.annotate-box');
         comment = $li.find('.comment');
         if(textarea.size() > 0) {
             //show save
             textarea.hide('slow', function(){ comment.empty(); comment.html($li.find('.comment-obj').attr('c').nl2br()) });
             $edit.attr("title", "Edit Comment");
             $edit.empty().append('<i class="icon-pencil"></i>');
             $del.empty().append('<i class="icon-trash"></i>');
             $del.attr("title", "Delete Comment");
             $del.unbind('click');
             $del.bind('click', (function(e) {
                 e.preventDefault();
                 del_annotation($li);
             }));
         }
     }




    function makeComment(annotation, parent) {
        if (parent.find('.annotate-area').size() == 0){
            parent.prepend('<ul class="annotate-area code-comment-box">');
        }
        var $li = $('<li class="comment"/>');
        var $div = $('<div class="comment-text-container">');

        if (annotation.edit) {
            var $hidden = $('<input class="comment-obj" type="hidden" o=\''+ annotation.o +'\' c=\'' + annotation.c + '\' cid="'+annotation.id+'" author=\''+annotation.name+'\'>');
            var $edit = $('<a href="#" class="comment-edit-link"><i class="icon-pencil"></i></a>').click(function(evt){
                evt.preventDefault();
                edit_annotation($li)
            });
            var $del = $('<a href="#" class="comment-del-link"><i class="icon-trash"></i></a>').click(function(evt){
                evt.preventDefault();
                del_annotation($li)
            })
            var $edit_div = $('<div class="pull-right annotation-edit">')
                .append($edit)
                .append($del)
                .append($hidden)
            $edit_div.appendTo($div)
        }

        $div.append('<div class="commentor">'+annotation.u+'</div>')
            .append('<div class="comment">'+annotation.c.nl2br()+'</div>')
            .append('<div class="timestamp">'+annotation.t+'</div>');
        $li
            .append('<img class="small-profile-pic" src="'+annotation.p+'" width="32" height="32" />')
            .append($div)
            .appendTo(parent.find('.annotate-area'));
        jfdiFormat($li.find('.comment').get(0));
    }

    function refreshComments(){
        $.get($('#annotation_path').val(), {
            annotation:{
            annotable_id: _cid,
            annotable_type: "StdCodingAnswer"
        }}, function(s){
            parseComments(s);
            setTimeout(refreshComments, 4000);
        });
    }
    var line_obj = [];
    var $_lines;
    var $_line_numbers = false;
    var $_comment_boxes = {};
    var _comments = [];

    var _annotate_ids = {};

    var start = false, end = false;
    var start_line = false, end_line = false;
    var fullScreenOffset = false;
    var hideAnnotate = false;
    var _cb_mw=0;

    if (typeof edit == 'undefined' || !edit){
        $output = $('<div class="static-code cm-s-'+theme+'"/>').appendTo($wrapper);
        var accum = [], zam = [];
        CodeMirror.runMode(_source_code, _language, function(string, style){
            if (string == "\n"){
                str = accum.join("");
                if (str == '') str = '\x20';
                zam.push('<pre class="line">'+str+"\n"+'</pre>');
                accum = [];
            }else if (style){
                accum.push("<span class=\"cm-" + style + "\">" + string + "</span>");
            }else{
                accum.push(string);
            }
        });
        if (accum.length){
            str = accum.join("");
            if (str == '') str = '\x20';
            zam.push('<pre class="line">'+str+'</pre>');
        }

        var code = zam.join("");
        $output.html('<div class="lines"></div><div class="source">'+code+'</div>');

        var topOffset = $output.find('div.source').offset().top;
        var bottomOffset = topOffset + $wrapper.height();
        setUpLines($("#output"));
        setUp();
    }else{
        console.log(code_id);
        var $code = $('<textarea class="code" name="code" id="code"></textarea>').val(source).appendTo($wrapper);
//        var $save = $('<input type="button" class="btn" value="Save Code" />').appendTo($wrapper);
        var editor = CodeMirror.fromTextArea($("#code").get(0), {
            //TODO:hard code language here
            mode: {name: "python",
                version: 3,
                singleLineStringErrors: false},
            lineNumbers: true,
            tabMode: "indent",
            theme: 'molokai',
            matchBrackets: true
        });

        editor.on('change',function(){
           $("#code_"+code_id).val(editor.getValue());
        });
//        $save.click(function(){
//            var $this = $(this);
//            $.post(makelink('code/_save_code'), {cid: code_id, c: editor.getValue()}, function(s){
//                $wrapper.find('.CodeMirror-scroll').effect('highlight');
//            });
//            window.onbeforeunload = null;
//        });

        //$(window).unload( function () {  } );
    }
    refreshComments();

    $("#commentButton").click(function(){
        if ($("#comment-ta").attr('disabled') == 'disabled') return false;
        var t = $("#comment-ta").val().trim();
        if (t == ''){
            $("#comment-ta").focus();
        }else{
            $("#comment-ta").attr('disabled','disabled');
            $.post(makelink('code/_comment'), {cid: _cid, comment: t }, function(s){
                s = JSON.parse(s);
                $("#comment-ta").attr('disabled',false).val('').focus();
                parseComments(s);
            });
        }
    });


    function fullScreen(){ // currently not working
        $wrapper.wrap('<div id="wrapper-container" />');
        $newWrapper = $wrapper.addClass('fullscreen').appendTo(document.body);
//		$(document).bind('scroll',checkScroll);
        $output.data('oheight', $output.height());
        if ($output.height() < $wrapper.height()){
            $output.height($wrapper.height()+'px');
        }

        var _kd;
        $(document.body).addClass('fullscreen').keydown(_kd = function(evt){
            var kc = (evt.which) || evt.keyCode;
            if (kc == 27){
                unfullScreen();
                $(this).unbind('keydown', _kd);
            }
        })
        ntopOffset = $newWrapper.find('.static-code').find('div.source').offset().top;
        fullScreenOffset = topOffset - ntopOffset; topOffset = ntopOffset;
        bottomOffset = topOffset + $newWrapper.height();
        checkScroll();
    }
    function unfullScreen(){
        $wrapper.appendTo($("#wrapper-container")).removeClass('fullscreen');
        $output.height($output.data('oheight'));
        topOffset = $output.find('div.source').offset().top;
        bottomOffset = topOffset + $wrapper.height();
        fullScreenOffset = false;

//		$(document).unbind('scroll',checkScroll);
        $(document.body).removeClass('fullscreen');
        $(document).scrollTop( topOffset - 40);
        checkScroll();
    }

    function hideAnnotation(){
        hideAnnotate = true;
        $('.comment-box').hide();
    }
    function showAnnotation(){
        hideAnnotate = false;
        checkScroll();
        $("#toggle-comment").removeClass('hide');
    }

    function selectAll() {
        if (document.selection) {
            var range = document.body.createTextRange();
            range.moveToElementText($output.find('.source').get(0));
            range.select();
        }else if (window.getSelection) {
            var range = document.createRange();
            range.selectNode($output.find('.source').get(0));
            window.getSelection().addRange(range);
        }
    }

    return {
        parseComments: parseComments,
        checkScroll: checkScroll,
        fullScreen: fullScreen,
        unfullScreen: unfullScreen,
        showAnnotation: showAnnotation,
        hideAnnotation: hideAnnotation,
        selectAll: selectAll
    };
}
