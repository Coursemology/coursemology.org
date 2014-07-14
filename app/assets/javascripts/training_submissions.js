$(document).ready(function(){
    $('#submit-btn').click(function(evt){
        $('#submit-btn').addClass('disabled');
        var form = $("#training-step-form");
        var update_url = form.children("input[name=update_url]").val();
        var qid = form.children("input[name=qid]").val();
        var checkboxes = form.find("input.choices");
        var choices = [];
        var aids = [];
        var current_step = form.children("input[name=current_step]").val();

        $.each(checkboxes, function(i, cb) {
            choices.push($(cb).val());
            if ($(cb).is(":checked")) {
                aids.push($(cb).val());
            }
        });

        if (aids.length > 0) {
            var data = {
                'current_step':current_step,
                'qid': qid,
                'aid': aids,
                'choices': choices
            }
            // send ajax request to get result
            // update result form
            // change submit to continue if the answer is correct
            $.post(update_url, data, function(resp) {
                $('#submit-btn').removeClass('disabled');

                $('#explanation .result').html(resp.result);
                $('#explanation .reason').html(resp.explanation);
                $('#explanation').removeClass('hidden');
                $('#explanation').removeClass('mcq-ans-incorrect');
                $('#explanation').removeClass('mcq-ans-correct');

                if (resp.is_correct) {
                    $('#continue-btn').removeClass('disabled');
                    $('#continue-btn').addClass('btn-primary');
                    $('#submit-btn').removeClass('btn-primary');
                    $('#explanation').addClass('mcq-ans-correct');
                } else {
                    $('#explanation').addClass('mcq-ans-incorrect');
                }
            }, 'json');
        }

        return false; // prevent default
    });

    $('#continue-btn').click(function(evt) {
        if ($(this).hasClass('disabled')) {
            evt.preventDefault();
        }
    });
    $("#pathrun").bind("click",submitCode);
    if(document.getElementById("ans")) {
        var pathcm;
        pathcm = CodeMirror.fromTextArea(document.getElementById("ans"), {
            mode: {name: "python",
                version: 3,
                singleLineStringErrors: false},
            lineNumbers: true,
            indentUnit: 4,
            tabMode: "shift",
            matchBrackets: true,
            theme:"molokai",
            extraKeys: {
                "Tab": function(){
                    pathcm.replaceSelection("    " , "end");
                }
            }
        });
        $(document).keydown(function(evt){
            if(evt.altKey && evt.which == 82){
                submitCode();
            }
        });
    };


    var running = false;
    function submitCode(){
        if(running) return;
        running = true;
        $("#pathrun").attr("disabled",true);
        var form = $("#training-step-form");
        var update_url = form.children("input[name=update_url]").val();
        var qid = form.children("input[name=qid]").val();
        var current_step = form.children("input[name=current_step]").val();

        var failcolor = {backgroundColor: "#e1c1b1"}
        var animateOpt = {duration: 1000, queue: false};
        var passcolor = {backgroundColor: "#008000"};
        $.post(update_url, {code: pathcm.getValue(),current_step:current_step,qid:qid}, function(resp){
            var $er = $("#eval_result");
            $(document.body).scrollTop(($er.offset().top + $er.height()) - $("#ruler").show().height() + 100);
            $("#ruler").hide();
            if(resp.errors.length > 0){
//                $er.text(resp.errors).animate({backgroundColor: "#3C2502",color:"#FF0000"}, animateOpt);
//                console.log("error")
                $er.html(escapeHtml(resp.errors)).animate({backgroundColor: "#e1c1b1"}, animateOpt);
            }else{
                var publicTestFlag = true;
                $("#publicTestTable tbody tr").each(function(index, e){
//                    console.log("change table")
                    if(resp.public[index]){
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
                var privateTestFlag = resp.private.length == 0 ? true : resp.private.reduce(function(a,b){return a && b});
                if(publicTestFlag){
                    if(resp.private == null || !privateTestFlag){
                        $er.html("Your answer failed to pass one or more of the private test cases."  + (resp.hint ? " <br>Hint: " + resp.hint : "")).animate(failcolor, animateOpt);
                    }else{
                        $er.html("You have successfully completed this step!").animate(passcolor, animateOpt);
                        $('#continue-btn').removeClass('disabled');
                        $("#pathrun").attr("disabled",true);
                        return; // we do not undisable the run
                    }
                }else{
                    $er.html("Your answer failed to pass one or more of the public test cases.").animate(failcolor,animateOpt);
                }
            }

            running = false;
            $("#pathrun").attr("disabled",false);
        }, 'json')
    }
});


