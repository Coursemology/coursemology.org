var path = function(){
    var saving = false;
    var cStep = null;
    var tPubic = 'public';
    var tPrivate = 'private';
    var tEval = 'eval';
    var $dataInput = null;

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
            private: [],
            public: [],
            eval: []
        },

        removeEmptyTestCases: function(data){
            var tcType = JSON.parse($("#tc-type-data").val());
            for (var type in tcType) {
                var tests = data[type];
                for (var i = tests.length-1; i >= 0; --i ){
                    if (tests[i].expected == "" || tests[i].expression == ""){
                        tests.splice(i,1);
                    }
                }
            }
        },

        saveQuestion: function(){
            saving = true;
            path.removeEmptyTestCases(path.data);
            $dataInput.val(JSON.stringify(path.data));
        },
        initialize: function() {
            $("#saveCQ").click(path.saveQuestion);
            cStep = path.data;
            $dataInput = $("#coding_question_data");
            var tcType = JSON.parse($("#tc-type-data").val());
            path.loadTestTypes(tcType);
            if( $dataInput.val() != "") {
                path.data =  JSON.parse($dataInput.val());
                path.loadStep();
            }
        },

        /** tests **/
        addTest: function(event){
            var testType = event.data.param1;
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
        loadTestTypes: function(tcType) {
            var $tcDiv = $("#path_testcases");
            for (var type in tcType) {
                $tcDiv.append($.tmpl("testcase_table", {type: type, title: tcType[type], has_hint: type == tPrivate}));
                $("#add-{0}-test".format(type)).click({param1: type}, path.addTest);
            }
        },
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
                } else {
                    cStep[tType] = [];
                }
            }
        }
    };
}();


$(document).ready(function() {
    //TODO: handle change of language
    var code_blocks = $("[render='code']");
    if (code_blocks.length > 0) {
        code_blocks.each(function(){
            $block = $(this);
            var language = $block.attr("language"), version = $block.attr("version");
            var cmBlock;
            var options = {
                mode: {name: language, version: version, singleLineStringErrors: false},
                lineNumbers: true,
                indentUnit: 4,
                tabMode: "shift",
                matchBrackets: true,
//                TODO: refactor theme
                theme:'molokai',
                extraKeys: {
                    "Tab": function(){
                        cmBlock.replaceSelection("    " , "end");
                    }
                }
            };
            cmBlock = CodeMirror.fromTextArea(this, options);
            cmBlock.on("change",function(){
                $block.val(cmBlock.getValue());
            });
        })
    }
    if(document.getElementById("pathstep_content")) {
        path.initialize();
    }
});
