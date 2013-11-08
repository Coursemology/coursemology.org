$(document).ready(function() {
  function LessonPlanEntryFormType(pickers) {
    var self = this;
    this.pickers = pickers;
    pickers.forEach(function(picker) {
      picker.onSelectionCompleted = function() { self.doneCallback.apply(self, arguments); }
    });
  }

  LessonPlanEntryFormType.prototype.pick = function() {
    if (this.$modal) {
        this.$modal.remove();
    }

    this.$modal = $('<div class="modal hide fade" />');
    this.pickers[0].pick(this.$modal[0]);
    this.$modal.modal();
  }

  LessonPlanEntryFormType.prototype.doneCallback = function(idTypePairList) {
    idTypePairList.forEach(function(x) {
      $element = $(tmpl('lesson-plan-resource', x));
      $("#linked_resources tbody").append($element);
    });
  };

  var LessonPlanEntryForm = new LessonPlanEntryFormType([new MaterialsFilePicker()]);

  $('.addresource-button').click(function() {
    LessonPlanEntryForm.pick();
  });
  $(document).on('click', '.resource-delete', null, function() {
    $(this).parents('tr').remove();
  });
  
  $('#lesson-plan-hide-all').click(function() {
    $('.lesson-plan-body').slideUp();
    $('.lesson-plan-body').data("hidden", "true");
    $('.lesson-plan-show-entries').show();
    $('.lesson-plan-hide-entries').hide();
  });
  
  $('#lesson-plan-show-all').click(function() {
    $('.lesson-plan-body').slideDown();
    $('.lesson-plan-body').data("hidden", "false");
    $('.lesson-plan-show-entries').hide();
    $('.lesson-plan-hide-entries').show();
  });
  
  $('.lesson-plan-header').click(function() {
    var parent = $(this).parents('.lesson-plan-item');
    var isHidden = $('.lesson-plan-body', parent).data("hidden");
    if (isHidden === "true") {
      $('.lesson-plan-body', parent).slideDown().data("hidden", "false");
      $('.lesson-plan-hide-entries', this).show();
      $('.lesson-plan-show-entries', this).hide();
    } else {
      $('.lesson-plan-body', parent).slideUp().data("hidden", "true");
      $('.lesson-plan-hide-entries', this).hide();
      $('.lesson-plan-show-entries', this).show();
    }
  });

  $('#lesson-plan-done-generating').click(function() {
    /*const*/ var DATE_FORMAT = 'DD-MM-YYYY';
    var has_errors = false;
    function show_error(id, error) {
      var group = $(id).parents('.control-group');
      group.addClass('error');
      $('.help-inline', group).text(error);
      has_errors = true;
    }
    function remove_error(id) {
      var group = $(id).parents('.control-group');
      group.removeClass('error');
      $('.help-inline', group).text('');
    }

    // Get the values from the form; make sure all fields are filled up.
    var milestone_count = $('input#input-number-milestones').val();
    if (!milestone_count) {
      show_error('input#input-number-milestones', 'This field is required');
    } else if (milestone_count <= 0) {
      show_error('input#input-number-milestones', 'The number of milestones to create should be a positive integer');
    } else {
      remove_error('input#input-number-milestones');
    }
    var milestone_length_in_days = $('input#input-length-milestones').val();
    if (!milestone_length_in_days) {
      show_error('input#input-length-milestones', 'This field is required');
    } else if (milestone_length_in_days <= 0) {
      show_error('input#input-length-milestones', 'The length of a milestone should be a positive integer');
    } else {
      remove_error('input#input-length-milestones');
    }
    var milestone_prefix = $('input#input-prefix-milestones').val();
    var first_milestone = $('input#input-start-milestones').val();
    if (!first_milestone) {
      show_error('input#input-start-milestones', 'This field is required');
    } else {
      remove_error('input#input-start-milestones');
    }

    if (has_errors) {
      return false;
    }

    var current_milestone = moment(first_milestone, DATE_FORMAT);
    var milestones = [];
    for (var i = 0; i < milestone_count; ++i) {
      current_milestone.add('days', parseInt(milestone_length_in_days));
      milestones.push({
        title: milestone_prefix + ' ' + (i + 1),
        end_at: current_milestone.clone()
      });
    }

    var promises = [];
    for (var i = 0; i < milestones.length; ++i) {
      var milestone = milestones[i];
      promises.push($.ajax({
        type: 'POST',
        url: 'lesson_plan/milestones.json',
        data: {
          lesson_plan_milestone: {
            title: milestone.title,
            description: '',
            end_at: milestone.end_at.format(DATE_FORMAT)
          }
        },
        dataType: 'json'
      }));
    }

    // Show the progress bar.
    var $modal = $(this).parents('.modal');
    $('.modal-body', $modal).addClass('hidden');
    $('#modal-loading', $modal).parent().removeClass('hidden');
    $('button.btn', $modal).addClass('disabled').prop('disabled', true);

    // Wait for all the requests to come back before closing the dialog.
    $.when.apply($, promises).then(function() {
      $modal.modal('hide');
      location.href = location.href;
    }, function() {
      alert('An error occurred while processing your request.');
      $modal.modal('hide');
      location.href = location.href;
    });
    return false;
  });
  
  $('.lesson-plan-entry-delete').click(function() {
    var parent = $(this).parents('.lesson-plan-entry');
    $(this).hide();
    var that = this;
    $('.lesson-plan-entry-delete-confirm', parent).fadeIn();
    setTimeout(function() { $('.lesson-plan-entry-delete-confirm', parent).hide(); $(that).fadeIn(); }, 5000);
  });
});
