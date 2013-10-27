function MaterialsFilePicker(callback) {
  this.doneCallback = callback;
  this.selectedMaterials = {};
  this.treeElement = $('#file-picker-tree');
  
  var courseId = gon.course;
  var that = this;
  $.ajax({
    url: '/courses/' + courseId + '/materials.json',
    success: that.onWorkbinStructureReceived
  });
}

MaterialsFilePicker.prototype.onSelectionCompleted = function() {
  this.doneCallback(this.selectedMaterials);
}

MaterialsFilePicker.prototype.onWorkbinStructureReceived = function(rootNode) {
  
}