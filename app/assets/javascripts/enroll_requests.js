$(document).ready(function(){

  function regularPost(action, input) {
      "use strict";
      var form;
      form = $('<form />', {
          action: action,
          method: 'POST',
          style: 'display: none;'
      });
      if (typeof input !== 'undefined') {
          $.each(input, function (name, value) {
              if ($.isArray(value)) {
                $(value).each(function(index) {
                  $('<input />', {
                      type: 'hidden',
                      name: name + '[]',
                      value: value[index]
                  }).appendTo(form);
                });
              } else {
                $('<input />', {
                    type: 'hidden',
                    name: name,
                    value: value
                }).appendTo(form);
              }
          });
      }
      console.log(form);
      form.appendTo('body').submit();
  }

  $('.check-all').change(function(evt) {
    var val = $(this).prop('checked');
    var target = $(this).attr('data-target');
    $(target).prop('checked', val);
    console.log(val);
    console.log(target);
  });

  $('.update-selected').click(function(evt){
    evt.preventDefault();
    // 1. get the link
    var url = $(this).attr('href');
    console.log(url);
    // 2. get the list of ids
    var target = $(this).attr('data-target');
    var selected_cb = $.grep($(target), function(cb) {return $(cb).prop('checked') });
    var selected_ids = $.map(selected_cb, function(cb) { return $(cb).val(); });
    var csrfName = $("meta[name='csrf-param']").attr('content');
    var csrfValue = $("meta[name='csrf-token']").attr('content');
    var inputs = {};
    inputs[csrfName] = csrfValue;
    inputs['ids'] = selected_ids;
    // 3. send a post request
    regularPost(url, inputs);
  });
});
