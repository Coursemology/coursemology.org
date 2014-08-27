$(document).ready(function() {
  // when click add requirement:
  // ajax to server to create the Requirement object
  // add it to the form list
  // when achievement is created, it check against the current
  // list to add or remove requirements
  // don't need to remove because there is no hard link from achievement to requirement
  // removing the requirement object will remove the thing itself.

  $('.add-ach-req').click(function(e) {
    e.preventDefault();
    var form_row = $(this).parents('tr');
    var selected = form_row.find('select :selected');
    var ach_id = selected.val();
    var create_url = $(this).attr('href');

    var data = {
      type: "Achievement",
      ach_id: ach_id
    };

    $.ajax({
      url: create_url,
      type: "POST",
      data: data,
      dataType: "html",
      success: function(resp) {
        form_row.before(resp);
        selected.detach();
        selected.prop('selected', false);
        form_row.find('select').append(selected);
      }
    });
  });

  $('.add-asm-req').click(function(e) {
    e.preventDefault();
    var form_row = $(this).parents('tr');
    var min_grade = form_row.find('input.asm-min-grade-input').val();
    var selected = form_row.find('select :selected');
    var asm_type = selected.attr('data-type');
    var asm_id = selected.val();
    var create_url = $(this).attr('href');
    var data = {
      type: "AsmReq",
      asm_id: asm_id,
      asm_type: asm_type,
      min_grade: min_grade
    };

    $.ajax({
      url: create_url,
      type: "POST",
      data: data,
      dataType: "html",
      success: function(resp) {
        form_row.before(resp);
        selected.detach();
        selected.prop('selected', false);
        form_row.find('select').append(selected);
      }
    });
  });

  $('.add-lvl-req').click(function(e) {
    e.preventDefault();
    var form_row = $(this).parents('tr');
    var selected = form_row.find('select :selected');
    var lvl_id = selected.val();
    var create_url = $(this).attr('href');

    var data = {
      type: "Level",
      lvl_id: lvl_id
    };

    $.ajax({
      url: create_url,
      type: "POST",
      data: data,
      dataType: "html",
      success: function(resp) {
        form_row.before(resp);
        selected.detach();
        selected.prop('selected', false);
        form_row.find('select').append(selected);
      }
    });
  });

  $(document).on('click', '.remove-req', function(e) {
    e.preventDefault();
    $(this).parents('tr').remove();
  });
  
  //ordering achievements
  $("table.achievement-list tbody").sortable({
  	cursor: 'move',
	helper: function(e, tr){
		var $originals = tr.children();
		var $helper = tr.clone();
	    $helper.children().each(function(index){		      
	      $(this).width($originals.eq(index).width());
	    });
	    return $helper;
	},
	start: function(event, ui) {
       	ui.item.data('old_pos',$('table.achievement-list tr').index(ui.item));	           
	},
	stop: function(event, ui) {		 
		var old_pos = ui.item.data('old_pos');
	    var new_pos = $('table.achievement-list tr').index(ui.item);	
	    if(old_pos != new_pos){
			var data = { arg : {pos : new_pos}, id : ui.item.find('input#achievement_id').val(), pos : new_pos, old_pos : ui.item.data('old_pos') };    			
	        update_achievement_pos(data);
        }	    
	}	
  });    
  $("table.achievement-list tbody").mousedown(function(){
	document.activeElement.blur();
  });
});

function update_achievement_pos(data){	
	var url = $('input.ajax_update_pos_url').val();		
	$.ajax({
		url : url,
		type : 'POST',
		dataType : 'json',
		data : data,
		async : false,
		success : function(result) {
			console.log(result);					
		}
	}); 	
}
