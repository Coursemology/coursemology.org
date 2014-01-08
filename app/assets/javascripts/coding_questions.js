(function() {
  "use strict";
  var cmPrefill;
  var cmIncluded;
  var path = function() {
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

    function changeLang(lang) {
      "use strict";
      cmPrefill.setOption("mode", val);
      cmIncluded.setOption("mode", val);
    }

    /** data types **/

    function _newTest(){
      return {
        expected: "",
        expression: ""
      };
    }

    return {
      data: {
        type: "do",
        included: "",
        prefill: "",
        privateTests: new Array(),
        publicTests: new Array(),
        evalTests: new Array()
      },

      savePath: function(){
        saving = true;
        $("#assessment_coding_question_data").val(JSON.stringify(path.data));
      },
      initialize: function() {
        $("#savePath").click(path.savePath);
        cStep = path.data;
        if( $("#assessment_coding_question_data").val() != "") {
          path.data =  JSON.parse($("#coding_question_data").val());
          path.loadStep();
        }
      },

      /** metadata **/
      changeLang: changeLang,
      changePrefill: function(val){
        cStep.prefill = val;
      },
      changeIncluded: function(val){
        cStep.included = val;
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

        _appendTest(testType, test_count, "", "");
      },
      updateTest: function(testType, testCount, expr, value){
        testCount--;
        eval('cStep.'+testType+'Tests['+testCount+'].'+expr+' = value');
      },
      deleteTest: function(testDiv, testType){
        var i = $(testDiv).attr("testNo");
        $(testDiv).remove();
        eval('cStep.'+testType+'Tests.splice(i-1,1)');
        $("#"+testType+"_test_tbody").children().each(function(index, e){
          $(e).attr("testNo", index+1);
        });
      } ,
      loadStep:function(){
        cStep = path.data;
        changeLang(cStep.language);

        $("#public_test_tbody").html("");
        $("#private_test_tbody").html("");
        $("#eval_test_tbody").html("");
        for(var i = 0 ; i < cStep.privateTests.length; i++){
          _appendTest("private",i+1, cStep.privateTests[i].expression, cStep.privateTests[i].expected);
        }
        for(var i = 0 ; i < cStep.publicTests.length; i++){
          _appendTest("public",i+1, cStep.publicTests[i].expression, cStep.publicTests[i].expected);
        }

        for(var i = 0 ; i < cStep.evalTests ? cStep.evalTests.length : 0; i++){
          _appendTest('eval', i + 1, cStep.evalTests[i].expression, cStep.publicTests[i].expected);
        }
        cmPrefill.setValue(cStep.prefill);
        if(cStep.included == null) cStep.included = "";
        cmIncluded.setValue(cStep.included);
      }
    };
  }();


  $(document).ready(function() {
    $('form.coding-question-form select.lang').change(function() {
      path.changeLang(this.value);
    });

    $('form.coding-question-form input#add-public-test').click(function() {
      path.addTest('public');
    });

    $('form.coding-question-form input#add-private-test').click(function() {
      path.addTest('private');
    });

    if (document.getElementById("pathstep_content")) {
      var options = {
        mode: {
          name: "python",
          version: 3,
          singleLineStringErrors: false
        },
        lineNumbers: true,
        indentUnit: 4,
        tabMode: "shift",
        matchBrackets: true,
        theme:'molokai'
      };

      cmPrefill = CodeMirror.fromTextArea(document.getElementById("prefilled"), options);
      cmIncluded = CodeMirror.fromTextArea(document.getElementById("included"), options);

      cmPrefill.on("change", function() {
        path.changePrefill(cmPrefill.getValue());
      });
      cmIncluded.on("change", function() {
        path.changeIncluded(cmIncluded.getValue());
      });
      path.initialize();
    }
  });
})();
