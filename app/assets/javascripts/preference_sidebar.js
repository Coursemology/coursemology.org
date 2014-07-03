$(document).ready(function() {
	$('#btn_add_item_sidebar').click(function(event) {
		var select_option = $('#course_navbar_preference_course_id').find(':selected');
		var tr_to_show = $('#btn_remove_' + $(select_option).val()).parent().parent();
		$(tr_to_show).removeClass('hidden_navbar_tr');
		$(tr_to_show).find('input[id*="is_enabled"]').prop('checked', true);
		$(select_option).remove();
	});
});

function hide_tr(e) {
	var tr_to_hide = $(e).parent().parent();
	$(tr_to_hide).addClass('hidden_navbar_tr');
	$(tr_to_hide).find('input[id*="is_enabled"]').prop('checked', false);
	$('#course_navbar_preference_course_id').append($('<option>', {
		value : $(e).attr('id').split('_')[$(e).attr('id').split('_').length - 1],
		text : $(tr_to_hide).children(':first').children(':first').val()
	}));
}