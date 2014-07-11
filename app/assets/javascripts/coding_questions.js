var path = function(){
    var saving = false;
    var cStep = null;
    var tPubic = 'public';
    var tPrivate = 'private';
    var tEval = 'eval';
    var $dataInput = null;

    function addslashes(str){
        return (str + '').replace(/[\"]/g, '&quot;');
    }
    function _appendTest(tcDetails){
        $("#{0}_test_tbody".format(tcDetails.tType)).append($.tmpl("testcase_row",tcDetails));
        $(".eval_expression, .expected_output, .fail_hint").unbind().change(function() {path.updateTest($(this))});
        $(".delete_test").unbind().click(function() {path.deleteTest(($(this)))});
    }

    /** data types **/

    function _newTest(){
        return {
            expected: "",
            expression: "",
            hint:""
        };
    }

    return {
        data: {
            type: "do",
            prefill: "",
            included: "",
            private: [],
            public: [],
            eval: []
        },

        saveQuestion: function(){
            saving = true;
            $dataInput.val(JSON.stringify(path.data));
        },
        initialize: function() {
            $("#saveCQ").click(path.saveQuestion);
            cStep = path.data;
            $dataInput = $("#coding_question_data");
            if( $dataInput.val() != "") {
                path.data =  JSON.parse($dataInput.val());
                path.loadStep();
            }
        },

        /** metadata **/
        changeLang: function(val){

            cStep.language = val;

            cmPrefill.setOption("mode",val);
            cmIncluded.setOption("mode",val);
        },
        changePrefill: function(val){
            cStep.prefill = val;
        },
        changeIncluded: function(val){
            cStep.included = val;
        },
        /** tests **/
        addTest: function(testType){
            var ci = cStep;
            var tNo = ci[testType].length;
            ci[testType].push(_newTest());

            _appendTest({
                tNo:tNo,
                tType: testType,
                expression: "",
                expected: "",
                fail_hint: "",
                has_hint: testType == tPrivate
            });
        },

        updateTest: function($ele){
            var $tr = $ele.parents(".test_case");
            var c = $tr.attr("data-test-no") - 0;
            var $eo = $tr.find(".expected_output");
            var $ep = $tr.find(".eval_expression");
            var $hint = $tr.find(".fail_hint");

            cStep[$tr.attr("data-test-type")][c] = {
                expression: $ep.val(),
                expected: $eo.val(),
                hint: $hint.val()
            };
        },

        deleteTest: function($del){
            var $tr = $del.parents(".test_case");
            var c = $tr.attr("data-test-no") - 0;
            var testType = $tr.attr("data-test-type");
            cStep[testType].splice(c, 1);
            $tr.remove();
            $("#"+testType+"_test_tbody").children().each(function(index, e){
                $(e).attr("data-test-no", index);
            });
        } ,
        loadStep:function(){
            cStep = path.data;

            $("#public_test_tbody").html("");
            $("#private_test_tbody").html("");
            $("#eval_test_tbody").html("");
            var i = 0;
            var testTypes = [tPubic, tPrivate, tEval];

            for (var tt in testTypes) {
                var tType = testTypes[tt];
                if(cStep[tType]) {
                    for(i = 0 ; i < cStep[tType].length; i++){
                        var tcDetail = cStep[tType][i];
                        tcDetail["tNo"] = i;
                        tcDetail["tType"] = tType;
                        tcDetail["has_hint"] = tType == tPrivate;
                        _appendTest(tcDetail);
                    }
                }
            }

            cmPrefill.setValue(cStep.prefill);
            if(cStep.included == null) cStep.included = "";
            cmIncluded.setValue(cStep.included);
        }
    };
}();


var cmPrefill;
var cmIncluded;

$(document).ready(function() {
    if(document.getElementById("pathstep_content")) {
        //TODO: refactoring
        var options1 = {
            mode: {name: "python",
                version: 3,
                singleLineStringErrors: false},
            lineNumbers: true,
            indentUnit: 4,
            tabMode: "shift",
            matchBrackets: true,
            theme:'molokai',
            extraKeys: {
                "Tab": function(){
                    cmPrefill.replaceSelection("    " , "end");
                }
            }
        };

        var options2 = {
            mode: {name: "python",
                version: 3,
                singleLineStringErrors: false},
            lineNumbers: true,
            indentUnit: 4,
            tabMode: "shift",
            matchBrackets: true,
            theme:'molokai',
            extraKeys: {
                "Tab": function(){
                    cmIncluded.replaceSelection("    " , "end");
                }
            }
        };



        cmPrefill = CodeMirror.fromTextArea(document.getElementById("prefilled"), options1);
        cmIncluded = CodeMirror.fromTextArea(document.getElementById("included"), options2);

        cmPrefill.on("change",function(){
            path.changePrefill(cmPrefill.getValue());
        });
        cmIncluded.on("change",function(){
            path.changeIncluded(cmIncluded.getValue());
        });
        path.initialize();
    }
});
