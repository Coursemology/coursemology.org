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
        $li
            .append('<img class="small-profile-pic" src="'+obj.p+'" width="32" height="32" />')
            .append('<div class="timestamp">'+obj.t+'</div>')
            .append('<div class="commentor">'+obj.u+'</div>')
            .append('<div class="comment">'+obj.c+'</div>');
        return $li;
    }
    self.makeHiddenBox = function(cnt,code_id){
        var $li = $('<li class="hidden"/>');

        $a = $('<a cnt="'+cnt+'" class="hidden" href="#">'+cnt+' other comments hidden</a>')
            .appendTo($li)
            .one('click',function(){
                $.post(makelink('code/_get_comments'), {cid: code_id}, function(s){
                    s = JSON.parse(s);
                    self.parseComment(s, code_id);
                });
                return false;
            }).click(function(){return false;});

        return $li;
    }
    self.makeTextarea = function($obj){
        var ecid = $obj.attr('ecid');
        var $li = $('<li class="textarea" />');
        $li.append('<textarea class="annotate-box" style="margin-bottom: 9px" />');

        var $but = $('<input type="button" value="comment" class="button" />').click(function(){
            var $ta = $(this).parent().find('textarea');
            if ($ta.attr('disabled') == 'disabled') return false;

            var t = $ta.val().trim();
            if (t == ''){
                $ta.focus();
            }else{
                $ta.attr('disabled','disabled');
                $.post($("#"+ecid+"_post_path").val(),{
                    comment:{
                        commentable_id: $("#"+ecid+"_commentable_id").val(),
                        commentable_type: $("#"+ecid+"_commentable_type").val(),
                        text: t
                    }}, function(s){
                        $ta.attr('disabled',false).val('').focus();
                        self.parseComment(s,ecid);
                    });
            }
        });
        $but.appendTo($li);
        return $li;
    }
    self.parseComment = function(comments,ecid){
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
                $li = self.makeComment(comments[i]);
            }
            if ($obj.data('hasComment')){
                $li.insertBefore($obj.data('hasComment'));
            }else{
                $li.appendTo($obj);
            }
            if ($li.find('.comment').size()){
                jfdiFormat($li.find('.comment').get(0));
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
