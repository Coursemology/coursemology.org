/**
 * Created with JetBrains RubyMine.
 * User: Raymond
 * Date: 23/7/13
 * Time: 2:22 PM
 * To change this template use File | Settings | File Templates.
 */

var codeEvaluator = function(){
    this.ans_ids = null;
    this.cvs = null;
    var self = this;
    this.running = false;

    var failcolor = {backgroundColor: "#e1c1b1"}
    var animateOpt = {duration: 1000, queue: false};
    var passcolor = {backgroundColor: "#008000"};

    return {
        testRun: function(ans_id, url, btn) {
            if (self.running) return;

            self.running = true;
            var index = self.ans_ids.indexOf(ans_id);
            var code = self.cvs[index].editor.getValue();
            $(btn).attr("disabled",true);
            var count_down = $("#run-count-down-"+ans_id);
            count_down.text(count_down.text() - 0 - 1);

            $.ajax({
                url: url,
                type: "POST",
                data: {
                    answer_id: ans_id,
                    code: code
                },
                dataType:"json",
                success: function(resp){
                    var $er = $("#eval-result-" + ans_id );
                    if(resp.errors.length > 0){
//                $er.text(resp.errors).animate({backgroundColor: "#3C2502",color:"#FF0000"}, animateOpt);
//                console.log("error")
                        $er.html(escapeHtml(resp.errors)).animate({backgroundColor: "#e1c1b1"}, animateOpt);
                    }else{
                        var publicTestFlag = true;
                        $("#public-test-table-" + ans_id + " tbody tr").each(function(index, e){
//                    console.log("change table")
                            if(resp.publicTests[index]){
                                var temp = $("td:last",e);
                                if(temp.hasClass("pathTestFail")){
                                    temp.switchClass("pathTestFail","pathTestPass").animate(passcolor,animateOpt);
                                }else if(!temp.hasClass("pathTestPass")){
                                    temp.addClass("pathTestPass").animate(passcolor,animateOpt);;
                                }
                            }else{
                                publicTestFlag = false;
                                var temp = $("td:last",e);
                                if(temp.hasClass("pathTestPass")){

                                    temp.switchClass("pathTestPass", "pathTestFail").animate(failcolor, animateOpt);
                                }else if(!temp.hasClass("pathTestFail")){
                                    temp.addClass("pathTestFail", 1000).animate(failcolor,animateOpt);
                                }
                            }
                        });
                        var privateTestFlag = resp.privateTests.length == 0 ? true : resp.privateTests.reduce(function(a,b){return a && b});
                        if(publicTestFlag){
                            if(resp.privateTests == null || !privateTestFlag){
                                $er.html("Your answer failed to pass one or more of the private test cases.").animate(failcolor, animateOpt);
                            }else{
                                $er.html("You have successfully passed all public and private test cases!").animate(passcolor, animateOpt);
                                $(btn).attr("disabled",true);
                                self.running = false;
                                return; // we do not undisable the run
                            }
                        }else{
                            $er.html("Your answer failed to pass one or more of the public test cases.").animate(failcolor,animateOpt);
                        }
                    }

                    $(btn).attr("disabled",false);
                    self.running = false;
                }
            });
        },
        init: function(ans_ids, cvs) {
            self.ans_ids = ans_ids;
            self.cvs = cvs;
        }
    }
}();

$(document).ready(function() {

    $.map($("#eval-error-message"), function(c, i){
        $(c).html(escapeHtml($(c).html()))
    });

    $('#mission_submit').click(function(e){
        saveCode();
        if(!confirm("THIS ACTION IS IRREVERSIBLE\n\nAre you sure you want to submit? You will no longer be able to amend your submission!")){
            e.preventDefault();
        }
    });

    var ans = $(".code-ans");
    var ans_ids;
    var cvs = [];

    $('#mission-save').click(function(e){
        saveCode();
    });

    function saveCode(){
        cvs.map(function(c, i){
            $("#code_" + ans_ids[i]).val(c.editor.getValue());
        });
    }

    if(ans.size() > 0) {

        ans_ids = $.map(ans, function(value, key){return $(value).val();});
        $.map(ans_ids, function(id, i){
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
        codeEvaluator.init(ans_ids, cvs);
    }
});