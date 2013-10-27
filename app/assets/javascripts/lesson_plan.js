function LessonPlanEntryFormType(pickers) {
  var self = this;
  this.pickers = pickers;
  pickers.forEach(function(picker) {
    picker.onSelectionCompleted = function() { self.doneCallback.apply(self, arguments); }
  });
}

LessonPlanEntryFormType.prototype.pick = function() {
  var $modal = $('<div class="modal hide fade" />');
  this.pickers[0].pick($modal[0]);
  $modal.modal();
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

var LessonPlanEntryForm = new LessonPlanEntryFormType([]);

$(document).ready(function() {
  $('.addresource-button').click(function() {
    LessonPlanEntryForm.pick();
  });
  $(document).on('click', '.resource-delete', null, function() {
    $(this).parents('tr').remove();
  });
});
