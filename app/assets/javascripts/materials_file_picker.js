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
  var selectedItems = [];
  for (var id in selectedMaterials) {
    var currentTuple = selectedMaterials[id];
    selectedItems.push(currentTuple);
  }
  
  this.doneCallback(selectedItems);
};

MaterialsFilePicker.prototype.onWorkbinStructureReceived = function(rootNode) {
  var shouldIncludeFiles = true;
  var treeData = parseFileJsonForJqTree(rootNode, shouldIncludeFiles);
  
  treeElement.tree({
    data: treeData,
    autoOpen: true,
    keyboardSupport: false    
  });
};
