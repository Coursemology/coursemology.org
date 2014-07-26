/**
 * Created with JetBrains RubyMine.
 * User: Raymond
 * Date: 23/7/13
 * Time: 5:17 PM
 * To change this template use File | Settings | File Templates.
 */
//ported from JFDI Academy
var Comment = (function(){
    var self = {};
    var _annotate_ids = {};

    self.makeComment = function(obj){
        var $li = $('<li class="comment"/>');
        $li.append('<a href="' + obj.f + '"><img class="small-profile-pic" src="'+obj.p+'" width="32" height="32" /></a>');
        var $div = $('<div class="comment-text-container">');
        $div.append('<div class="commentor">'+obj.u+'</div>')
            .append('<div class="comment">'+obj.c.nl2br()+'</div>')
            .append('<div class="timestamp">'+obj.t+'</div>')
            .appendTo($li);
        return $li;
    }

    self.makeEditableComment = function(obj, ecid) {
        var $li = $('<li class="comment"/>');
        $li.append('<a href="' + obj.f + '"><img class="small-profile-pic" src="'+obj.p+'" width="32" height="32" /></a>');
        var $div = $('<div class="comment-text-container">');
        var $hidden = $('<input class="comment-obj" type="hidden" o="" c="" cid="" author="" >');
        $hidden.attr('o', obj.o);
        $hidden.attr('c', obj.c);
        $hidden.attr('cid', obj.id);
        $hidden.attr('author', obj.name);
        var $edit = $('<a href="#" class="comment-edit-link" rel="tooltip" data-original-title="Edit Comment"><i class="icon-pencil"></i></a>').click(function(evt){
            evt.preventDefault();
            self.edit_comment($li, ecid)
        });
        var $del = $('<a href="#" class="comment-del-link"  rel="tooltip" data-original-title="Delete Comment"><i class="icon-trash"></i></a>').click(function(evt){
            evt.preventDefault();
            self.del_comment($li, ecid)
        })

        $div.append($('<div class="pull-right comment-edit">').append($edit).append($del))
            .append('<div class="commentor">'+obj.u+'</div>')
            .append('<div class="comment">'+obj.c.nl2br()+'</div>')
            .append('<div class="timestamp">'+obj.t+'</div>')
            .append($hidden)
            .appendTo($li);

        return $li;
    }

    self.edit_comment = function($li, ecid){
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
            $edit.attr("data-original-title", "Save Comment");
            $edit.empty().append('<i class="icon-ok"></i>');
            $del.empty().append('<i class="icon-remove"></i>');
            $del.attr("data-original-title", "Cancel Edit");
            $del.unbind('click');
            $del.bind('click', (function(e) {
                e.preventDefault();
                self.quit_comment_edit($li, ecid);
            }));
        } else {
            //save comment
            $.ajax({
                url:$("#"+ecid+"_post_path").val()+"/"+id,
                type: "PUT",
                dataType:"json",
                data: {
                    text: textarea.val()
                },
                success: function(resp) {
                    $obj.attr('o', resp.o);
                    $obj.attr('c', resp.c);

                    self.quit_comment_edit($li, ecid)
                }
            });
        }
    }

    self.quit_comment_edit = function($li, ecid){
        $edit = $li.find('.comment-edit-link');
        $del = $li.find('.comment-del-link');
        var textarea = $li.find('.annotate-box');
        comment = $li.find('.comment');
        if(textarea.size() > 0) {
            //show save
            console.log($li.find('.comment-obj').attr('c'));
            textarea.hide('slow', function(){ comment.empty(); comment.html($li.find('.comment-obj').attr('c').nl2br()) });
            $edit.attr("data-original-title", "Edit Comment");
            $edit.empty().append('<i class="icon-pencil"></i>');
            $del.empty().append('<i class="icon-trash"></i>');
            $del.attr("data-original-title", "Delete Comment");
            $del.unbind('click');
            $del.bind('click', (function(e) {
                e.preventDefault();
                self.del_comment($li, ecid);
            }));
        }
    }

    self.del_comment = function($li, ecid) {
        $obj = $li.find('.comment-obj');
        if(!confirm("TO DELETE: \n\n"+ $obj.attr('o') + "\n\nBY: " + $obj.attr('author') )) {
            return;
        }

        $.ajax({
                url:$("#"+ecid+"_post_path").val()+"/"+$obj.attr('cid'),
                type: "DELETE",
                dataType:"json",
                success: function(e) {
                    $li.hide('slow', function(){ $li.remove(); });
                }
            }
        )
    }

    self.makeHiddenBox = function(cnt, ecid){
        var $li = $('<li class="hidden"/>');

        $a = $('<a cnt="'+cnt+'" class="hidden" href="#">'+cnt+' other comments hidden</a>')
            .appendTo($li)
            .one('click',function(){
                $.post($("#"+ecid+"_post_path").val()+"/get_comments",{
                    origin: $("#submission_url_"+ecid).val(),
                    comment:{
                        // TODO: store the comment_topic id for easy retrieval
                        topic_id: $("#"+ecid+"_commentable_id").val(),
                        topic_type: $("#"+ecid+"_commentable_type").val()
                    },
                    brief: true},
                    function(s){
                    self.parseComment(s, ecid);
                });
            }).click(function(){return false;});

        return $li;
    }
    self.makeTextarea = function($obj){
        var ecid = $obj.attr('ecid');
        var $li = $('<li class="textarea" />');
        $li.append('<textarea class="annotate-box" style="margin-bottom: 9px" />');

        var $but = $('<a href="#" class="btn">Comment</a>').click(function(evt){
            evt.preventDefault();
            var $ta = $(this).parent().find('textarea');
            if ($ta.attr('disabled') == 'disabled') return false;

            var t = $ta.val().trim();
            if (t == ''){
                $ta.focus();
            }else{
                $ta.attr('disabled','disabled');
                $.post($("#"+ecid+"_post_path").val(),{
                    origin: $("#submission_url_"+ecid).val(),
                    comment:{
                        commentable_id: $("#"+ecid+"_commentable_id").val(),
                        commentable_type: $("#"+ecid+"_commentable_type").val(),
                        text: t
                    }}, function(s){
                    $ta.attr('disabled',false).val('').focus();
                    self.parseComment(s, ecid);
                });
            }
        });

        $but.appendTo($li);
        return $li;
    }
    self.parseComment = function(comments, ecid){
        var $obj = $('.code-comment-box[ecid="'+ecid+'"]');
        var hidden = false,replace = false;;
        for (var i=0;i<comments.length && !hidden;++i){
            hidden = hidden || (typeof comments[i].h != 'undefined' );
        }

        if (!hidden && $obj.data('hasHidden')){
            $obj.find('li.comment,li.hidden').remove().data('hasHidden',false);
            replace = true;
        }

        for (var i=0;i<comments.length;++i){
            var $li;
            if (typeof comments[i].id != 'undefined' && !replace && typeof _annotate_ids[comments[i].id] != 'undefined') continue;
            _annotate_ids[comments[i].id] = true;

            if (typeof comments[i].s != 'undefined' && comments[i].s != -1) continue;
            if (typeof comments[i].h != 'undefined' ){
                $li = self.makeHiddenBox(comments[i].h, ecid);
                $obj.data('hasHidden',true);
            }else{
                if(comments[i].edit) {
                    $li = self.makeEditableComment(comments[i], ecid);
                }
                else {
                    $li = self.makeComment(comments[i]);
                }
            }
            if ($obj.data('hasComment')){
                $li.insertBefore($obj.data('hasComment'));
            }else{
                console.log('appending');
                $li.appendTo($obj);
            }
            if ($li.find('.comment').size()){
                coursemologyFormat($li.find('.comment').get(0));
            }
        }
    }

    self.init = function(ecid, comment, ajax){
        var $obj = $('.code-comment-box[ecid="'+ecid+'"]');

        if (typeof comment!='undefined' && comment){
            var $li = self.makeTextarea($obj);
            $obj.append($li).data('hasComment', $li)
        }

        if (typeof ajax != 'undefined' && ajax){
            // factoring not completed
        }

    }

    return self;
})();

$(function(){
    $('.mission-pending a').click(function(){
        var $this = $(this);
        $.post($("#comments_togging_path").val(),
            {
                cid: $(this).attr('cid')
            },
            function(s){
                if ($this.text().trim() == 'Mark as pending'){
                    $this.text('Unmark as pending');
                } else {
                    $this.text('Mark as pending');
                }
            });
        return false;
    });
});
