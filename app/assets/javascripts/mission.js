$(document).ready(function(){

  // Make the table rows (the questions / asm-qns) sortable
  $(".asm-qns").sortable({
    update: function(event, ui){

      // create a list of asm_qns' id, based on the order in the DOM
      var asm_qns_positions = $(this).sortable('serialize');

      // send post request to the controller than can reorder asm_qns
      var asm_qns_reorder_url = $(this).attr('url');
      $.ajax({
        url: asm_qns_reorder_url,
        type: "POST",
        data: asm_qns_positions
      });

      // update question number in the view
      var question_headers = $(".asm-qn-handler > h3", this.children);
      $.each(question_headers, function(index, question_header){
        var old_header = $(question_header).text();
        var new_header = old_header.replace(/Question [0-9]+/, "Question " + (index + 1).toString());
        $(question_header).text(new_header);
      });
    }
  });

});
