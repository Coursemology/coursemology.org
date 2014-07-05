$(document).ready(function() {
	$('#btn_add_sidebar_item').click(function(e) {			
		e.preventDefault(); 
		var $select_option = $('#course_navbar_preference_course_id').find(':selected');
		if($select_option.val()){			       
			var data = { func : 'add', id : $select_option.val() };  
			sidebar_update_values(data, this);		
		}		
	});
	
	$('.btn-remove-sidebar-item').click(function(e) {
        e.preventDefault();        
		var data = { func : 'remove', id : '0' };  
		sidebar_update_values(data, this);                	   
    });
    
	$('input[id*="course_course_navbar_preferences_attributes"][id*="name"]').change(function(e) {
    	e.preventDefault();            
        var data = { func : 'update_name', id : '0', name : $(this).val() };    
        sidebar_update_values(data, this);        
              
    });

	$('input[id*="course_course_navbar_preferences_attributes"][id*="pos"]').each(function(e) {
            $(this).data("old_value", $(this).val());
	});
	
    $('input[id*="course_course_navbar_preferences_attributes"][id*="pos"]').change(function(e) {
    	e.preventDefault();
    	if(isNaN($(this).val())){
			$(this).val($(this).data("old_value"));
    	}else{
	        var data = { func : 'update_pos', id : '0', pos : $(this).val() };    
	        sidebar_update_values(data, this);	        
       }
    });
    
    $('input[id*="course_course_navbar_preferences_attributes"][id*="is_displayed"]').change(function(e) {
		e.preventDefault();         	
        var data = { func : 'update_is_displayed', id : '0', checked : $(this).is(":checked") };          	
        sidebar_update_values(data, $(this).parent());         
    });    
    
    $('input[id*="ip_display_st_level_ach"]').change(function(e) {    	
    	e.preventDefault();
    	var id = $(this).attr('id').split('_')[$(this).attr('id').split('_').length - 1];	
        var data = { func : 'update_display_st_level_ach',id : id, checked : $(this).is(":checked") };         	
        sidebar_update_values(data, this);         
    });    
});

function update_layout_pos(handler, index, count){
	var $tr_to_change = $(handler).parent().parent();
	var item = $tr_to_change.find('input.sidebar-item-name').val();       
	var $litag = $('ul#navbar_tabs span#badge_' + item).parent().parent().clone();	
	$('ul#navbar_tabs span#badge_' + item).parent().parent().remove();
	if(parseInt(index) <= parseInt(count - 2)){
		$('ul#navbar_tabs li:eq(' + index + ')').before($litag);
	}else {
		$('ul#navbar_tabs li:eq(' + (parseInt(index)-1) + ')').after($litag);
	}
	$(handler).data("old_value", $(handler).val());
}

function update_layout_name(handler){
	var $tr_to_change = $(handler).parent().parent();
	var item = $tr_to_change.find('input.sidebar-item-name').val();        
	var $atag = $('ul#navbar_tabs span#badge_' + item).parent();
	var $children = $atag.children();	
	$atag.empty();	
	$atag.append($children.eq(0));	
	$atag.append($(handler).val());
	$atag.append($children.eq(1)); 
}

function update_layout_remove(handler){
	var $tr_to_hide = $(handler).parent().parent();
	$tr_to_hide.find('input[id*="is_enabled"]').prop('checked', false);        
	$tr_to_hide.addClass('hidden_navbar_tr');
	$('#course_navbar_preference_course_id').append($('<option>', {
		value : $tr_to_hide.next().val(),
		text : $tr_to_hide.children(':first').children(':first').val()
	}));
	var item = $tr_to_hide.find('input.sidebar-item-name').val();
	$('ul#navbar_tabs span#badge_' + item).parent().parent().hide(); 

}

function update_layout_add(handler ,result){
	var $tr_to_show = $('input:hidden[value="'+ result.id +'"]').prev();		
	$tr_to_show.find('input[id*="is_enabled"]').prop('checked', true);
	$tr_to_show.removeClass('hidden_navbar_tr');
	$('#course_navbar_preference_course_id').find(':selected').remove();
			
	var litag = '<li>';
	litag += 		'<a href="' + result.url + '">';
	litag += 			'<span class="nav-icon">';
	litag += 				'<i class="' + result.icon + '"></i>';
	litag += 			'</span>';
	litag += 			result.name;
	litag += 			'<span id="badge_' + result.item + '" class="sidenav-count" style="display: none"></span>';
	litag +=		'</a>';
	litag +=	'</li>';
	
	if(parseInt(result.index) <= parseInt(result.count) - 1){
		$('ul#navbar_tabs li:eq(' + result.index + ')').before(litag);
	}else {
		$('ul#navbar_tabs li:eq(' + (parseInt(result.index)-1) + ')').after(litag);
	}
}

function sidebar_update_values(data, handler){		
	var course_id = $('div.div-add-item-sidebar input.sidebar-course-id').val();        
	var url = '/courses/' + course_id + '/preferences/sidebar_update_values';		
	if(data.func != 'add' && data.func != 'update_display_st_level_ach'){
		data.id = $(handler).parent().parent().next().val();	
	}		
	$.ajax({
		url : url,
		type : 'POST',
		dataType : 'json',
		data : data,
		success : function(result) {
			if (data.func == 'add' && result != null){
				update_layout_add(handler ,result);
			}else if (data.func == 'remove' && result.status == 'OK'){
				update_layout_remove(handler);
			}else if (data.func == 'update_name' && result.status == 'OK'){
				update_layout_name(handler);
			}else if (data.func == 'update_pos' && !isNaN(result.index)){				
				update_layout_pos(handler,result.index, result.count);
			}			
		}
	}); 	
}
