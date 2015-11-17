/**
 * Created with JetBrains RubyMine.
 * User: Raymond
 * Date: 23/7/13
 * Time: 2:26 PM
 * To change this template use File | Settings | File Templates.
 */

//code from JFDI acedamy

function CodeViewer($wrapper, source, theme, code_id, sub_id, _vt, language){
    var self = this;
    var edit = _vt =='edit';
    this.wrapper = $wrapper;
    this.code_id = code_id;
    this.cb_class = "comment-box-"+code_id;
    this.sub_id = sub_id;

    function setUpLines(){
        var $lines = self.output.find("div.lines");
        var i = 1;

        function box_mdown(e){
            e.stopPropagation();
            if ($(this).hasClass('annotate')){
                $(this).data('lh').eq(0).click();
            }else if (self.end_line == $(this).data('l')){
                self.start = this;
                self.start_line = $(this).data('l');
            }
            return false;
        }
        function box_over(){
            self.end = this;
            el = $(this).data('l');
            if (!self.start) self.start_line = el;
            var s = (self.start_line < el) ? self.start_line : el;
            var e = (self.start_line > el) ? self.start_line : el;

            for (var i=0;i<_comments.length;++i){
                if (_comments[i].s >= s && _comments[i].s <= e) return false;
                if (_comments[i].s <= s && _comments[i].s >= e) return false;
                if (_comments[i].e >= s && _comments[i].e <= e) return false;
                if (_comments[i].e <= s && _comments[i].e >= e) return false;
                if (_comments[i].s <= s && _comments[i].e >= e) return false;
            }

            self.end_line = $(this).data('l');
            s = (self.start_line < self.end_line) ? self.start_line : self.end_line;
            e = (self.start_line > self.end_line) ? self.start_line : self.end_line;
            if (self.start){ // dragging in action
                self.line_numbers.removeClass('hover').slice(s,e+1).addClass('hover');
                $_lines.removeClass('highlight').slice(s,e+1).addClass('highlight');
            }
            $(this).addClass('hover');
        }
        function box_out(){
            if (!self.start){
                $(this).removeClass('hover');
                $_lines.removeClass('highlight');
            }
        }
        function box_up(){
            if (self.start){
                var s = (self.start_line < self.end_line) ? self.start_line : self.end_line;
                var e = (self.start_line > self.end_line) ? self.start_line : self.end_line;
                self.line_numbers.removeClass('hover');
                createComment(s+1, e+1,false, true);
                if (self.hideAnnotate) self.showAnnotation();
                self.start = false;
            }
        }


        $_lines = self.output.find('pre.line');
        $_lines.each( function() {
            line_obj.push( this );
            var $l = $('<div class="line-number line-number-'+ self.code_id +'">'+i+'</div>');
            $l.css('height', $(this).height() + 'px')
                .css('line-height',($(this).height() +3)+ 'px')
                .css('top', ($(this).offset().top -self.topOffset)+ 'px')
                .data('l',i-1)
                .appendTo($lines);
            ++i;
        });
//		if (_ca){
        self.line_numbers = $('.line-number-' + self.code_id)
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
            .data('s', self.start_line+1).data('e', self.end_line+1)
            .appendTo($ab);
        $ab.append('<button class="btn" id="annotateButton">Annotate</button>');
        this.append($ab);

        $ta.focus();
        var $annotateButton = $("#annotateButton")
        $("#annotateButton").on('click',function(){
            var $ab = $("#annotate-box");
            if ($ab.attr('disabled') == 'disabled') return false;
            var t = $ab.val().trim();
            var s = $ab.data('s'), e = $ab.data('e');
            if (t == ''){
                $ab.focus();
            }else{
                $ab.attr('disabled','disabled');
                $annotateButton.attr('disabled','disabled');
                $.ajax({
                    type: "POST",
                    url: self.annotation_url,
                    data: {
                        origin: document.URL,
                        submission_id: self.sub_id,
                        annotation: {
                            annotable_id: self.code_id,
                            annotable_type: "Assessment::Answer",
                            text: t,
                            line_start: s,
                            line_end: e
                        }
                    }
                })
                .done(function(s) {
                    $ab.attr('disabled', false).val('');
                    $annotateButton.html('Annotate').attr('class', 'btn').attr('disabled', false);
                    parseComments(s);
                })
                .fail(function() {
                    $ab.attr('disabled', false);
                    $annotateButton.html('Failed, Click to retry').attr('class', 'btn btn-danger').attr('disabled', false);
                });
            }
        });
    }
    function createComment(start, end, callback, temporary) {
        console.log("create comment");
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
            var $cb = $('<div class="comment-box ' + self.cb_class +'" '+(temporary ? 'id="temporary-comment-box"':'')+'/>');
            $cb.click(function(){
                if ($active != $cb)
                    activateComment($cb);
            });

            if (!line_obj[start-1])return false;
            $cb.appendTo(document.body);
            $cb
                .css('width', _cb_mw+'px')
                .css('top', ($(line_obj[start-1]).offset().top)+'px')
                .data('top', ($(line_obj[start-1]).offset().top) + self.wrapper.scrollTop())
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
        self.line_numbers.slice(start-1, end).removeClass('annotate').data('lh', false);
    }
    function addLineHighlighter(start, end) {
        $lh = $_lines.slice(start-1, end).addClass('annotate');
        self.line_numbers.slice(start-1, end).addClass('annotate').data('lh', $lh);
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
    function sanctifyCommentsHtmlTags(string){
        if(string.charAt(0) != '#') {
            return string;
        }
        return string.replace(/(>|<)/g, "<span class=\"cm-comment\">$1</span>");
    };
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
            self.start_line = $com.data('s')-1;
            self.end_line = $com.data('e')-1;
            addAnnotateBox.call($com);
        }
        self.checkScroll();
    }

    this.checkScroll = function(evt) {
        if (self.hideAnnotate) return true;

        var st = self.wrapper.scrollTop();
        $('.' + self.cb_class).each( function() {
            var $this = $(this);
            var ct = $this.data('top');
            ct -= st;
            if (self.fullScreenOffset) ct -= self.fullScreenOffset
            if (false && self.fullScreenOffset){
//				$this.css('top', ct+'px').show();
            }else{
                if (ct < self.topOffset || ct + 20 >= self.bottomOffset) {
                    if ($this.is('#temporary-comment-box')){
//                        removeComment.call($this);
                        $this.fadeOut('fast');
                    }else{
                        $this.fadeOut('fast');
                    }
                } else {
                    if (!$this.is(':visible')) {
                        $this.fadeIn('fast');
                    }
                    if (self.fullScreenOffset && ct + $this.height() > self.bottomOffset){
                        $this.css('top','auto').css('bottom',  '0px');
                    }else{
                        $this.css('bottom','auto').css('top', ct+'px');
                    }
                }
            }
        });
        return true;
    };

    function setUp() {
        self.wrapper.bind("scroll", self.checkScroll);

        // check height
        if (self.output.height() < self.wrapper.height()){
            self.wrapper.height(self.output.height()+'px');
        }
        // check width

        self.output.width(self.wrapper.get(0).scrollWidth);

        // check annotation width
        var x = function(){
            var len = $(document).scroll().width() - self.wrapper.offset().left - self.wrapper.width();
            _cb_mw = len;
        };
        x();
    }

    function parseComments(annotations){
        if (typeof Comment != 'undefined'){
            Comment.parseComment(annotations, self.code_id);
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
        self.checkScroll.call(this.wrapper);
    }

    function del_annotation($li) {
        $obj = $li.find('.comment-obj');
        if(!confirm("TO DELETE: \n\n"+ $obj.attr('o') + "\n\nBY: " + $obj.attr('author') )) {
            return;
        }

        $.ajax({
                url: self.annotation_url +"/"+$obj.attr('cid'),
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
                url:self.annotation_url +"/"+$obj.attr('cid'),
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
            var $hidden = $('<input class="comment-obj" type="hidden" o="" c="" cid="" author="" >');
            $hidden.attr('o', annotation.o);
            $hidden.attr('c', annotation.c);
            $hidden.attr('cid', annotation.id);
            $hidden.attr('author', annotation.name);
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
            .append('<a href="' + annotation.f + '"><img class="small-profile-pic" src="'+annotation.p+'" width="32" height="32" /></a>')
            .append($div)
            .appendTo(parent.find('.annotate-area'));
        coursemologyFormat($li.find('.comment').get(0));
    }

    function refreshComments(){
        $.get(self.annotation_url, {
            annotation:{
                annotable_id: self.code_id,
                annotable_type: "Assessment::Answer"
            }}, function(s){
            parseComments(s);
            setTimeout(refreshComments, 6000);
        });
    }
    var line_obj = [];
    var $_lines;
    this.line_numbers = false;
    var $_comment_boxes = {};
    var _comments = [];

    var _annotate_ids = {};

    this.start = false;
    this.end = false;
    this.start_line = false;
    this.end_line = false;
    this.fullScreenOffset = false;
    this.hideAnnotate = false;
    var _cb_mw=0;
    this.annotation_url = $("#annotation-path-" + self.code_id).val();

    if (typeof edit == 'undefined' || !edit){
        console.log(code_id);
        this.output = $('<div class="static-code cm-s-'+theme+'"'+ 'id="' + code_id +'"/>').appendTo(this.wrapper);
//        console.log(this.output);
        var accum = [], zam = [];
        CodeMirror.runMode(source, language, function(string, style){
            if (string == "\n"){
                str = accum.join("");
                if (str == '') str = '\x20';
                zam.push('<pre class="line">'+str+"\n"+'</pre>');
                accum = [];
            }else if (style){
                string = sanctifyCommentsHtmlTags(string);
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
        this.output.html('<div class="lines"></div><div class="source">'+code+'</div>');

        this.topOffset = this.output.find('div.source').offset().top;
        this.bottomOffset = this.topOffset + this.wrapper.height();
        setUpLines($("#output"));
        setUp();
        refreshComments();
    }else{
        console.log(code_id);
        var $code = $('<textarea class="code" name="code" id="code' + this.wrapper.attr("id") + '"></textarea>').val(source).appendTo(this.wrapper);
//        var $save = $('<input type="button" class="btn" value="Save Code" />').appendTo(this.wrapper);
        this.editor = CodeMirror.fromTextArea($("#code" +  this.wrapper.attr("id") ).get(0), {
            //TODO:hard code language here
            mode: {name: language,
                version: 3,
                singleLineStringErrors: false},
            lineNumbers: true,
            tabMode: "shift",
            theme: 'molokai',
            indentUnit: 4,
            matchBrackets: true
        });


//        $save.click(function(){
//            var $this = $(this);
//            $.post(makelink('code/_save_code'), {cid: code_id, c: editor.getValue()}, function(s){
//                this.wrapper.find('.CodeMirror-scroll').effect('highlight');
//            });
//            window.onbeforeunload = null;
//        });

        //$(window).unload( function () {  } );
    }


    $("#commentButton").click(function(){
        if ($("#comment-ta").attr('disabled') == 'disabled') return false;
        var t = $("#comment-ta").val().trim();
        if (t == ''){
            $("#comment-ta").focus();
        }else{
            $("#comment-ta").attr('disabled','disabled');
            $.post(makelink('code/_comment'), {cid: self.code_id, comment: t }, function(s){
                s = JSON.parse(s);
                $("#comment-ta").attr('disabled',false).val('').focus();
                parseComments(s);
            });
        }
    });
}

CodeViewer.prototype = {
    fullScreen: function() { // currently not working
        this.wrapper.wrap('<div id="wrapper-container' + this.code_id +'" />');
        $newWrapper = this.wrapper.addClass('fullscreen').appendTo(document.body);
    //		$(document).bind('scroll',checkScroll);
        this.output.data('oheight', this.output.height());
        if (this.output.height() < this.wrapper.height()){
            this.output.height(this.wrapper.height()+'px');
        }

        var _kd;
        var self = this;
        $(document.body).addClass('fullscreen').keydown(_kd = function(evt){
            var kc = (evt.which) || evt.keyCode;
            if (kc == 27){
                self.unfullScreen();
                $(this).unbind('keydown', _kd);
            }
        });
        var ntopOffset = $newWrapper.find('.static-code').find('div.source').offset().top;
        this.fullScreenOffset = this.topOffset - ntopOffset; this.topOffset = ntopOffset;
        this.bottomOffset = this.topOffset + $newWrapper.height();
        this.checkScroll();
    },
    unfullScreen: function() {
        if(!this.wrapper.hasClass('fullscreen')) {
            return;
        }
        this.wrapper.appendTo($("#wrapper-container" + this.code_id)).removeClass('fullscreen');
        this.output.height(this.output.data('oheight'));
        this.topOffset = this.output.find('div.source').offset().top;
        this.bottomOffset = this.topOffset + this.wrapper.height();
        this.fullScreenOffset = false;

    //		$(document).unbind('scroll',checkScroll);
        $(document.body).removeClass('fullscreen');
        $(document).scrollTop( this.topOffset - 40);
        this.checkScroll();
    },

    hideAnnotation: function() {
        this.hideAnnotate = true;
        $('.' + this.cb_class).hide();
    },

    showAnnotation: function() {
        this.hideAnnotate = false;
        this.checkScroll();
        $("#toggle-comment-" + this.code_id ).removeClass('hide');
    },

    selectAll: function() {
        if (document.selection) {
            var range = document.body.createTextRange();
            range.moveToElementText(this.output.find('.source').get(0));
            range.select();
        }else if (window.getSelection) {
            var range = document.createRange();
            range.selectNode(this.output.find('.source').get(0));
            window.getSelection().addRange(range);
        }
    }
};
