var path = function(){
    var saving = false;
    var cStep = null;

    function addslashes(str){
        return (str + '').replace(/[\"]/g, '&quot;');
    }
    function _appendTest(testType, test_count, expression, expected){
        $("#"+testType+"_test_tbody").append('<tr testNo="'+test_count+'">' +
            '<td><input type="text" value="'+addslashes(expression)+'" onchange="path.updateTest(\''+testType+'\', this.parentNode.parentNode.getAttribute(\'testNo\'), \'expression\', this.value)" /></td>'+
            '<td><input type="text" value="'+addslashes(expected)+'" onchange="path.updateTest(\''+testType+'\', this.parentNode.parentNode.getAttribute(\'testNo\'), \'expected\', this.value)" /></td>'+
            '<td><a  title="Delete this test" class = "btn btn-danger" onclick="path.deleteTest(this.parentNode.parentNode, \''+testType+'\')"><i class="icon-trash"></i></a></td></tr>');
    }

    /** data types **/

    function _newTest(){
        return {
            expected: "",
            expression: ""
        };
    }

    function _reorderSteps(){
        $("#path_step").children().each(function(index, e){
            e.id = "step_"+(index+1);
        });
    }
    return {
        data: {
            type: "do",
            language: "python",
            timeLimitInSec: "1",
            memoryLimitInMB: "2",
            included: "",
            prefill: "",
            privateTests: new Array(),
            publicTests: new Array()
        },

        savePath: function(){
            saving = true;
            $("#coding_question_data").val(JSON.stringify(path.data));
            $.post("path_create.php",{data: JSON.stringify(path.data)}, function(data){
                saving = false;
                if(data[2] != true){
                    alert("Saving failed for some reason. Your path data is either invalid in some way (e.g. have empty test cases) or your data is corrupted and saving was blocked. \n\nReason given:\n"+data[2]);
                }else{
                    if(path.data.id == null){
                        alert("Success. New path created and saved to database.");
                    }else{
                        alert("Existing path successfully saved!");
                    }
                    path.data.id = data[0];
                    path.data.timestamp = data[1];
                }
            }, 'json');
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
            cStep.changeTimeLimit = val;
        },

        /** tests **/
        addTest: function(testType){
            var test_count = null;
            var ci = cStep;
            if(testType=="public"){
                ci.publicTests.push(_newTest());
                test_count = ci.publicTests.length;
            }else{
                ci.privateTests.push(_newTest());
                test_count = ci.privateTests.length;
            }

            _appendTest(testType, test_count, "", "");
        },
        updateTest: function(testType, testCount, expr, value){
            testCount--;
            eval('cStep.'+testType+'Tests['+testCount+'].'+expr+' = value');
        },
        deleteTest: function(testDiv, testType){
            var i = $(testDiv).attr("testNo");
            $(testDiv).remove();
            eval('cStep.'+testType+'Tests.remove(i-1)');
            $("#"+testType+"_test_tbody").children().each(function(index, e){
                $(e).attr("testNo", index+1);
            });
        } ,
        loadStep:function(){
            cStep = path.data;
//            path.changeLang(cStep.language);

            $("#timeLimit").attr("value", cStep.timeLimitInSec);
            $("#memoryLimit").attr("value", cStep.memoryLimitInMB);
            $("#public_test_tbody").html("");
            $("#private_test_tbody").html("");
            for(var i = 0 ; i < cStep.privateTests.length; i++){
                _appendTest("private",i+1, cStep.privateTests[i].expression, cStep.privateTests[i].expected);
            }
            for(var i = 0 ; i < cStep.publicTests.length; i++){
                _appendTest("public",i+1, cStep.publicTests[i].expression, cStep.publicTests[i].expected);
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
        var options = {
            mode: {name: "python",
                version: 3,
                singleLineStringErrors: false},
            lineNumbers: true,
            indentUnit: 4,
            tabMode: "shift",
            matchBrackets: true
        };

        cmPrefill = CodeMirror.fromTextArea(document.getElementById("prefilled"), options);
        cmIncluded = CodeMirror.fromTextArea(document.getElementById("included"), options);

        cmPrefill.on("change",function(){
            path.changePrefill(cmPrefill.getValue());
        });
        cmIncluded.on("change",function(){
            path.changeIncluded(cmIncluded.getValue());
        });
        path.initialize();
    }
});
