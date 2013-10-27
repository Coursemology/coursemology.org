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
    $("#linked_resources tbody").append(
      '<tr>\n\
         <td>' + x + '<input type="hidden" name="resources[]" value="' + x[0] + ',' + x[1] + '" /></td>\n\
         <td>&nbsp;</td>\n\
         <td><span class="btn btn-danger"><i class="icon-trash"></i></span></td>\n\
       </tr>');
  });
};

var LessonPlanEntryForm = new LessonPlanEntryFormType([]);

$(document).ready(function() {
  $('.addresource-button').click(function() {
    LessonPlanEntryForm.pick();
  });
});
