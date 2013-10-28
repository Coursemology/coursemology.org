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
      $element = $('<tr>\n\
        <td>' + x[2] + '</td>\n\
        <td>&nbsp;</td>\n\
        <td>\n\
          <span class="btn btn-danger resource-delete"><i class="icon-trash"></i></span>\n\
          <input type="hidden" name="resources[]" value="' + x[0] + ',' + x[1] + '" />\n\
        </td>\n\
      </tr>');
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
    $('.lesson-plan-body').fadeOut();
    $('.lesson-plan-show-entries').show();
    $('.lesson-plan-hide-entries').hide();
  });
  
  $('#lesson-plan-show-all').click(function() {
    $('.lesson-plan-body').fadeIn();
    $('.lesson-plan-show-entries').hide();
    $('.lesson-plan-hide-entries').show();
  });
  
  $('.lesson-plan-hide-entries').click(function() {
    $(this).hide();
    var parent = $(this).parent();
    $(parent).children('.lesson-plan-body').fadeOut();
    $(parent).children('.lesson-plan-show-entries').show();
  });
  
  $('.lesson-plan-show-entries').click(function() {
    $(this).hide();
    var parent = $(this).parent();
    $(parent).children('.lesson-plan-body').fadeIn();
    $(parent).children('.lesson-plan-hide-entries').show();
  });
});
