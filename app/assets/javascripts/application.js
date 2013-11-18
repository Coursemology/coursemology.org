// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui.min
//= require jquery-fileupload
//= require tree.jquery
//
//= require bootstrap-dropdown
//= require bootstrap-transition
//= require bootstrap-collapse
//= require bootstrap-button
//= require bootstrap-tooltip
//
//= require bootstrap-colorpicker
//= require bootstrap-datetimepicker
//= require bootstrap-select
//
//= require bootstrap-modal
//= require bootstrap-wysihtml5
//= require scrolltofixed
//
//= require jquery.purr
//= require best_in_place
//= require codemirror
//= require codemirror/modes/python
//= require codemirror/addons/runmode/runmode
//= require codemirror/addons/edit/matchbrackets
//= require moment
//
//= require_self
//= require_tree .

$(document).ready(function() {

    var datetimepickers = $('.datepicker, .datetimepicker');
    $('.datetimepicker').datetimepicker({
        format: 'dd-MM-yyyy hh:mm',
        language: 'en-US',
        collapse: false,
        pickSeconds: false,
        maskInput: true
    });

    $('.datepicker').datetimepicker({
        format: 'dd-MM-yyyy',
        language: 'en-US',
        pickTime: false,
        collapse: false,
        maskInput: true
    });

    $('.datetimepicker.future-only:not(.past-only)').datetimepicker('setStartDate', new Date());
    $('.datepicker.future-only:not(.past-only)').datetimepicker('setStartDate', moment().add('d', 1).startOf('day').toDate());
    $('.datetimepicker.past-only:not(.future-only)').datetimepicker('setEndDate', new Date());
    $('.datepicker.past-only:not(.future-only)').datetimepicker('setEndDate', moment().subtract('d', 1).endOf('day').toDate());

    // Extra code so that we will use the HTML5 data attribute of a date picker if we have one; otherwise
    // we let the code above handle it for us. The behaviour of a date picker becomes more and more specific.
    //
    // This also displays placeholder text so users know what format the date/time picker expects for keyboard
    // input.
    datetimepickers.each(function() {
      var $this = $(this);
      var default_registered = false;
      function set_default_date(date) {
        if (default_registered) {
          return;
        }

        default_registered = true;
        $this.on('show', function() {
          // If we have no date set, we will jump the date picker to somewhere in the start/end range.
          var picker = $this.data('datetimepicker');
          if (!$this.val()) {
            var now = new Date();
            if (date < now || now < date) {
              picker.setDate(date);
              picker.setDate(null);
            }
          }
        });
      }

      // TODO: The dates are passed through moment because of a bug in bootstrap-datetimepicker:
      // https://github.com/tarruda/bootstrap-datetimepicker/issues/210
      // Furthermore, it's not following HTML5 specification: names split by hyphens are not camelCased.
      if ($this.data('dateStartdate')) {
        var date = moment($this.data('dateStartdate')).toDate();
        $this.datetimepicker('setStartDate', date);
        set_default_date(date);
      }
      if ($this.data('dateEnddate')) {
        var date = moment($this.data('dateEnddate')).toDate();
        $this.datetimepicker('setEndDate', date);
        set_default_date(date);
      }

      var dateTimeFormatString = $this.data('datetimepicker').format;
      var inputElement = $('input', this);
      if (!inputElement.attr("placeholder")) {
        // We only replace the placeholder if there isn't already one.
        inputElement.attr("placeholder", dateTimeFormatString);
      }
    });

    $('*[rel=tooltip]').tooltip();

    $('.colorpicker').colorpicker();
    $('.selectpicker').selectpicker();

    $('.delete-button').click(function() {
      var parent = $(this).parents('.delete-confirm-control-group');
      $(this).hide();
      var that = this;
      $('.delete-confirm-button', parent).fadeIn();
      setTimeout(function() { $('.delete-confirm-button', parent).hide(); $(that).fadeIn(); }, 2000);
    });

    $('.btn-hover-text').hover(
        function() {
            var $this = $(this); // caching $(this)
            $this.text($this.data('alt'));
        },
        function() {
            var $this = $(this); // caching $(this)
            $this.text($this.data('original'));
        }
    );

    $(function(){
        $(".jfdiCode").each(_jfdiFormatFunc);
    });

    $(function(){
        page_header = $(".page-header h1");
        if (page_header.size() <= 0)
            return;
        page_name =page_header[0].innerHTML.replace(/\s/g,"-");
        if (!page_name || page_name.indexOf('!') > 0 || page_name.indexOf(':') > 0)
            return;
        //<input type="hidden" id="<%= item[:text] %>_count" value="<%= item[:count] %>">
        badge_count = $("#"+page_name+"_count");
        if (badge_count.size() <= 0)
            return;
        new_items_seen = $(".new_"+page_name).size();
        //<i class="<%= item[:icon] %>" id="badge_<%= item[:text] %>"></i>
        set_badge = $("#badge_"+page_name);
        if (new_items_seen >0 && set_badge.size() > 0) {
            update_count = badge_count.val() - new_items_seen;
            if (update_count > 0)
                set_badge[0].innerHTML = update_count;
            else
                set_badge.addClass("hidden");
        }
    });
    $(':input[type=number]' ).live('mousewheel',function(e){ $(this).blur(); });

    // Make sure that any form elements with an error class are propagated
    // upwards to the parent control group
    $('.control-group label.error, .control-group div.error').each(function(n, element) {
      $(element).parents('.control-group').addClass('error');
    });

    // Make sure that all links with the disabled tag or disabled attribute
    // do not trigger a navigation
    $('body').on('click', 'a.btn.disabled, a.btn[disabled]', function(e) {
      e.preventDefault();
    });
});

// Define our framework for implementing client-side form validation.
jQuery.fn.extend({
  /// Validatr will find all forms in the queried set, and register
  /// submission handlers. Validation will be triggered before submit
  /// and blocked when errors occur.
  ///
  /// It also takes an array of tuples where the first element is a
  /// string (selector from the set), or a jQuery object, and the
  /// second element is the validation callback for the element.
  /// The validation callback can return a promise to defer the operation,
  /// a falsey value to validate; or a string or an array of error
  /// messages to display.
  validatr: function(elements) { //to not name conflict with the jQuery plugin
    function show_error($this, error) {
      var group = $this.parents('.control-group');
      group.addClass('error');

      // Create the help message span if none exists.
      var $message = $('.help-inline', group);
      if ($message.length === 0) {
        $message = $('<span class="help-inline"></span>');
        $message.appendTo($this.parent());
      }

      $message.text(error);
    }

    function remove_error($this) {
      var group = $this.parents('.control-group');
      group.removeClass('error');
      $('.help-inline', group).remove();
    }

    // Generates a handler which will set the appropriate fields with
    // the error message returned from the validator function.
    function generateElementValidator(handler) {
      return function() {
        var result = handler.apply(this, arguments);
        var $this = $(this);

        function process_result(result) {
          if (!result) {
            remove_error($this);
          } else if (typeof result === 'object' &&
            typeof result['promise'] === 'function') {
            result.done(function(value) {
              process_result(value);
            });
          } else {
            if (typeof result === 'string') {
              result = [result];
            }
            show_error($this, result);
          }
        }

        process_result(result);
      };
    }

    function validateForm() {
      if ($('.error', this).length > 0) {
        e.preventDefault();
      }
    }

    // Register all the callbacks for the form elements
    for (var i = 0; i < elements.length; ++i) {
      var pair = elements[i];
      var set = pair[0];
      if (typeof set === 'string') {
        set = $(set, this);
      }

      set.change(generateElementValidator(pair[1]));
    }

    // Register the callback for when the form should be submitted.
    $(this).submit(validateForm);
    $('input[type="submit"]', this).click(function() {
      handlevalidateForm.apply($(this).parents('form')[0], arguments);
    });
  }
});

var _jfdiFormatFunc = function(i, d){

    if ($(d).data('jfdiFormatted')) return;
    $(d).data('jfdiFormatted', true);
    if($(d).hasClass("pythonCode")){
        CodeMirror.runMode($(d).text(), "python", d);
    }
}
function jfdiFormat(element){
    $(element).find(".jfdiCode").each(_jfdiFormatFunc);
}

String.prototype.nl2br = function(){
    return (this + '').replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1<br />$2');
};

function IsNumeric(input) {
    return (input - 0) == input && input.length > 0;
}

function IsPositive(input) {
    return IsNumeric(input) && (input - 0) >= 0
}
