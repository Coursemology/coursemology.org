$(document).ready(function() {
	$('#btn_add_sidebar_item').click(function(e) {			
		e.preventDefault(); 
		var $select_option = $('#course_navbar_preference_course_id').find(':selected');
		if($select_option.val()){			       
			var data = {add : true, id : $select_option.val(), arg : {is_enabled : true}, success_func : function(result){
					if(result != null){
						update_layout_add(result);
					}					
				}
			};  
			sidebar_update_values(data);		
		}		
	});
	
	$('input[id*="ip_display_st_level_ach"]').change(function(e) {    	
    	e.preventDefault();
    	var id = $(this).attr('id').split('_')[$(this).attr('id').split('_').length - 1];	
        var data = { func : 'update_display_st_level_ach',id : id, checked : $(this).is(":checked") };         	
        update_display_student_level_achievement(data);         
    });
    
	$('.btn-remove-sidebar-item').click(function(e) {
        set_event_remove(e,this);                	   
    });
    
	$('input[id*="course_course_navbar_preferences_attributes"][id*="name"]').change(function(e) {
		set_event_update_name(e,this);
	});

	$('input[id*="course_course_navbar_preferences_attributes"][id*="name"]').each(function(e) {
            $(this).data("old_value", $(this).val());
	});	
	    
    $('input[id*="course_course_navbar_preferences_attributes"][id*="is_displayed"]').change(function(e) {
		set_event_update_displayed(e,this);		         
    });       
    
	$("#tb_course_navbar_preferences tbody").sortable({
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
			$hd_input = ui.item.next('tr').next('input').clone();
			ui.item.next('tr').next('input').remove();			
	        ui.item.data('hd_input',$hd_input);
	        ui.item.data('old_pos',$('#tb_course_navbar_preferences tr').index(ui.item));	        
	    },
		stop: function(event, ui) {
			var $temp_tr = ui.item;
			var old_pos = ui.item.data('old_pos');
			//arrange if getting wrong position
			if(ui.item.next('input').length){
				$next_hd_input = ui.item.next('input');
				$temp_tr = ui.item.clone();				
				$next_hd_input.after($temp_tr);
				$temp_tr.after(ui.item.data('hd_input'));
				ui.item.remove();
			}else{
				ui.item.after(ui.item.data('hd_input'));
			}
			//set event again			
			$temp_tr.find('.btn-remove-sidebar-item').click(function(e) {
		        set_event_remove(e,this);                	   
		    });		    
			$temp_tr.find('input[id*="course_course_navbar_preferences_attributes"][id*="name"]').change(function(e) {
				set_event_update_name(e,this);
			});		
			$temp_tr.find('input[id*="course_course_navbar_preferences_attributes"][id*="name"]').each(function(e) {
		            $(this).data("old_value", $(this).val());
			});				    
		    $temp_tr.find('input[id*="course_course_navbar_preferences_attributes"][id*="is_displayed"]').change(function(e) {
				set_event_update_displayed(e,this);		         
		    });	    
		    
		    //update database
		    var index = $('#tb_course_navbar_preferences tr').index($temp_tr);			
			var data = { arg : {pos : index}, id : $temp_tr.next('input').val(), pos : index, old_pos : old_pos, success_func : function(result){
				if(result != null && !isNaN(result.index)){
						update_layout_pos($temp_tr,result.index, result.count);
					}
				}
			};    			
	        sidebar_update_values(data);	    
	    }	
	});    
	$("#tb_course_navbar_preferences tbody").mousedown(function(){
	  document.activeElement.blur();
	});

});

function set_event_remove(e, handler){
	e.preventDefault();
	var id = $(handler).parent().parent().next().val();	
	var data = { arg : {is_enabled : false}, id : id, success_func : function(result){
			if(result != null && result.status == 'OK'){
				update_layout_remove(handler);
			}
		}
	};  
	sidebar_update_values(data);		
}

function set_event_update_name(e, handler){
	e.preventDefault();
	   if($(handler).val() === ''){
		$(handler).val($(handler).data("old_value"));
    }else{            
    	var id = $(handler).parent().parent().next().val();
	    var data = { arg : {name : $(handler).val()}, id : id, success_func : function(result){
				if(result != null && result.status == 'OK'){
					update_layout_name(handler);
				}
			}
		};    
	    sidebar_update_values(data);	       
	}
}

function set_event_update_displayed(e, handler){
	e.preventDefault();
	var id = $(handler).parent().parent().parent().next().val();       	
	var data = { arg : {is_displayed : $(handler).is(":checked")}, id : id, success_func : function(result){} };          	
    sidebar_update_values(data);
}
function update_layout_pos(handler, index, count){	
	var item_name = handler.find('input.sidebar-item-name').val();       
	var $litag = $('li#li_' + item_name).clone();	
	$('li#li_' + item_name).remove();
	if(parseInt(index) <= parseInt(count - 2)){
		$('ul#navbar_tabs li:eq(' + index + ')').before($litag);
	}else {
		$('ul#navbar_tabs li:eq(' + (parseInt(index)-1) + ')').after($litag);
	}
	$(handler).data("old_value", $(handler).val());
}

function update_layout_name(handler){
	var item_name = $(handler).parent().parent().find('input.sidebar-item-name').val();
	$('span#sp_text_' + item_name).text($(handler).val());
	$(handler).data("old_value", $(handler).val());
}

function update_layout_remove(handler){
	var $tr_to_hide = $(handler).parent().parent();
	$tr_to_hide.find('input[id*="is_enabled"]').prop('checked', false);        
	$tr_to_hide.addClass('hidden_navbar_tr');
	$('#course_navbar_preference_course_id').append($('<option>', {
		value : $tr_to_hide.next().val(),
		text : $tr_to_hide.children(':first').children(':first').val()
	}));
	var item_name = $tr_to_hide.find('input.sidebar-item-name').val();
	$('li#li_' + item_name).hide(); 

}

function update_layout_add(result){
	var $tr_to_show = $('input:hidden[value="'+ result.id +'"]').prev();		
	$tr_to_show.find('input[id*="is_enabled"]').prop('checked', true);
	$tr_to_show.removeClass('hidden_navbar_tr');
	$('#course_navbar_preference_course_id').find(':selected').remove();
			
	var litag = '<li id="li_' + result.item + '">';
	litag += 		'<a href="' + result.url + '">';
	litag += 			'<span class="nav-icon">';
	litag += 				'<i class="' + result.icon + '"></i>';
	litag += 			'</span>';
	litag += 			'<span id="sp_text_' + result.item + '">' + result.name + '</span>';
	litag += 			'<span id="badge_' + result.item + '" class="sidenav-count" style="display: none"></span>';
	litag +=		'</a>';
	litag +=	'</li>';
	
	if(parseInt(result.index) <= parseInt(result.count) - 1){
		$('ul#navbar_tabs li:eq(' + result.index + ')').before(litag);
	}else {
		$('ul#navbar_tabs li:eq(' + (parseInt(result.index)-1) + ')').after(litag);
	}
}

function sidebar_update_values(data){	
	var url = $('input.hdf-ajax-update-navbar-url').val();		
	$.ajax({
		url : url,
		type : 'POST',
		dataType : 'json',
		data : data,
		success : function(result) {
			data.success_func(result);					
		}
	}); 	
}

function update_display_student_level_achievement(data){
	var url = $('input.hdf-ajax-update-level-ach-url').val();	
	$.ajax({
		url : url,
		type : 'POST',
		dataType : 'json',
		data : data,
		success : function(result) {					
		}
	}); 	
}