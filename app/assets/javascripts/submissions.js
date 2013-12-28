/**
 * Created with JetBrains RubyMine.
 * User: Raymond
 * Date: 23/7/13
 * Time: 2:22 PM
 * To change this template use File | Settings | File Templates.
 */


$(document).ready(function() {

    $('#mission_submit').click(function(e){
        saveCode();
        if(!confirm("THIS ACTION IS IRREVERSIBLE\n\nAre you sure you want to submit? You will no longer be able to amend your submission!")){
            e.preventDefault();
        }
    });

    var qns = $(".code-qn");
    var qn_ids;
    var cvs = [];

    $('#mission-save').click(function(e){
        saveCode();
    });

    function saveCode(){
        cvs.map(function(c, id){
            $("#code_" + qn_ids[id]).val(c.editor.getValue());
        });
    }

    if(qns.size() > 0) {

        qn_ids = qns.map(function(m, n){return $(n).val();});
        $.map(qn_ids, function(id, i){
            var _source_code = $("#code_" + id).val();
            var _vt = $("#mode_" + id).val();
            var _language = $("#code-language-" + id).val();
            var cv = new CodeViewer($("#source-code-"+id), _source_code, 'molokai', id, _vt, _language);
            cvs.push(cv);
//        cv.parseComments(_c);

//        $("#permissions li").hover(function(){
//            $(this).addClass('hover');
//        }, function(){
//            $(this).removeClass('hover');
//        }).bind('click', function(){
//                    if ($(this).hasClass('sel')) return;
//                    $("#permissions li").removeClass('sel');
//                    p = $(this).hasClass('public') ? 'public' : 'private';
//                    $(this).addClass('sel');
//
//                    $.post(makelink('code/_set_permission'), {cid: _cid, p: p}, function(s){
//                    });
//                });

            $("#delete-code").click(function(){
                return (confirm('Are you sure you want to delete this awesome source code?'));
            });
            $("#fullscreen-link-"+id).click(function(){
                cv.fullScreen();
                return false;
            });
            $("#toggle-comment-" + id).click(function(){
                var $this = $(this);
                if ($this.hasClass('disabled')){
                    $this.removeClass("disabled");
                    cv.showAnnotation();
                }else{
                    cv.hideAnnotation();
                    $this.addClass('disabled');
                }
                return false;
            });
            $("#select-all-code-"+id).click(function(){
                cv.selectAll();
                return false;
            });
        })
    }
});