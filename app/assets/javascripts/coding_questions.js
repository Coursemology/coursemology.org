var path = function(){
    var saving = false;
    var cStep = null;

    function addslashes(str){
        return (str + '').replace(/[\"]/g, '&quot;');
    }
    function _appendTest(testType, test_count, expression, expected, hint){
        $("#"+testType+"_test_tbody").append('<tr testNo="'+test_count+'">' +
            '<td><input type="text" value="'+addslashes(expression)+'" onchange="path.updateTest(\''+testType+'\', this.parentNode.parentNode.getAttribute(\'testNo\'), \'expression\', this.value)" /></td>'+
            '<td style="border-left: 0"><input type="text" value="'+addslashes(expected)+'" onchange="path.updateTest(\''+testType+'\', this.parentNode.parentNode.getAttribute(\'testNo\'), \'expected\', this.value)" /></td>'+
            '<td><a  title="Delete this test" class = "btn btn-danger" onclick="path.deleteTest(this.parentNode.parentNode, \''+testType+'\')"><i class="icon-trash"></i></a></td></tr>' +
            (testType == 'private' ? '<tr><td colspan="2" style="border-top: 0">Hint: <textarea style="width: 98%;" rows="2" onchange="path.updateTest(\''+testType+'\',' + test_count + ', \'hint\', this.value)">' + addslashes(hint) + '</textarea></td><td style="border-top: 0"></td></tr>' : ''));
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
            language: "python",
            timeLimitInSec: "1",
            memoryLimitInMB: "2",
            testLimit: "3",
            included: "",
            prefill: "",
            privateTests: new Array(),
            publicTests: new Array(),
            evalTests: new Array()
        },

        savePath: function(){
            saving = true;
            $("#coding_question_data").val(JSON.stringify(path.data));
        },
        initialize: function() {
            $("#savePath").click(path.savePath);
            cStep = path.data;
            if( $("#coding_question_data").val() != "") {
                path.data =  JSON.parse($("#coding_question_data").val());
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
        changeMemoryLimit:function(val){
            cStep.memoryLimitInMB = val;
        },
        changeTimeLimit: function(val){
            cStep.timeLimitInSec = val;
        },

        changeTestLimit: function(val){
            cStep.testLimit = val;
        },

        /** tests **/
        addTest: function(testType){
            var test_count = null;
            var ci = cStep;
            if(testType=="public"){
                ci.publicTests.push(_newTest());
                test_count = ci.publicTests.length;
            }else if (testType == 'private'){
                ci.privateTests.push(_newTest());
                test_count = ci.privateTests.length;
            } else {
                ci.evalTests.push(_newTest());
                test_count = ci.evalTests.length;
            }

            _appendTest(testType, test_count, "", "","");
        },
        updateTest: function(testType, testCount, expr, value){
            testCount--;
            eval('cStep.'+testType+'Tests['+testCount+'].'+expr+' = value');
        },
        deleteTest: function(testDiv, testType){
            var i = $(testDiv).attr("testNo");
            if (testType == 'private')
                $(testDiv).next().remove();
            $(testDiv).remove();
            eval('cStep.'+testType+'Tests.splice(i-1,1)');
            $("#"+testType+"_test_tbody").children().each(function(index, e){
                $(e).attr("testNo", index+1);
            });
        } ,
        loadStep:function(){
            cStep = path.data;
//            path.changeLang(cStep.language);

            $("#timeLimit").attr("value", cStep.timeLimitInSec);
            $("#memoryLimit").attr("value", cStep.memoryLimitInMB);
            $("#testLimit").val(cStep.testLimit);
            $("#public_test_tbody").html("");
            $("#private_test_tbody").html("");
            $("#eval_test_tbody").html("");
            for(var i = 0 ; i < cStep.privateTests.length; i++){
                _appendTest("private",i+1, cStep.privateTests[i].expression, cStep.privateTests[i].expected, cStep.privateTests[i].hint || "" );
            }
            for(var i = 0 ; i < cStep.publicTests.length; i++){
                _appendTest("public",i+1, cStep.publicTests[i].expression, cStep.publicTests[i].expected, cStep.publicTests[i].hint || "" );
            }
            for(var i = 0 ; i < (cStep.evalTests ? cStep.evalTests.length : 0); i++){
                console.log(cStep.evalTests);
                _appendTest('eval', i + 1, cStep.evalTests[i].expression, cStep.evalTests[i].expected, cStep.publicTests[i].hint || "" );
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
