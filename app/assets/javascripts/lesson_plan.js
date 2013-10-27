function LessonPlanEntryForm(pickers) {
  pickers.forEach(function(picker) {
    picker.onSelectionCompleted = this.doneCallback;
  });
}

LessonPlanEntryForm.prototype.doneCallback = function(idTypePairList) {
  
};