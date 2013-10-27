function MaterialsFilePicker() {
  this.selectedMaterials = {};
}

MaterialsFilePicker.prototype.pick = function(div) {
  var courseId = gon.course;
  var that = this;
  $.ajax({
    url: '/courses/' + courseId + '/materials.json',
    success: function(rootNode) { that.onWorkbinStructureReceived(rootNode); }
  });
  
  var htmlContent = '<div class="modal-header">\
  <h3>Select Files</h3>\
  </div>\
  <div class="modal-body">\
  <div id="file-picker-tree"></div>\
  </div>\
  <div class="modal-footer">\
    <div id="done-picking" data-dismiss="modal" class="btn btn-primary">\
      Done\
    </div>\
    <button data-dismiss="modal" class="btn">\
      Cancel\
    </button>\
  </div>';

  $(div).html(htmlContent);
  this.treeElement = $('#file-picker-tree', div);
  
  $("#done-picking", div).on('click', function() { that.onDone(); });
}

MaterialsFilePicker.prototype.onDone = function() {
  console.log("Test.");
  var selectedItems = [];
  for (var id in this.selectedMaterials) {
    var currentTuple = this.selectedMaterials[id];
    selectedItems.push(currentTuple);
  }
  
  this.onSelectionCompleted(selectedItems);
};

MaterialsFilePicker.prototype.onWorkbinStructureReceived = function(rootNode) {
  var shouldIncludeFiles = true;
  var treeData = parseFileJsonForJqTree(rootNode, shouldIncludeFiles);
  
  this.treeElement.tree({
    data: treeData,
    autoOpen: true,
    keyboardSupport: false
  });
  var that = this;
  this.treeElement.bind('tree.click', function() { that.onNodeClicked(); } );
};

MaterialsFilePicker.prototype.onNodeClicked = function(event) {
  // Disable single selection: click to select for everything.
  event.preventDefault();
  
  var selectedNode = event.node;
  var nodeId = selectedNode.id;
  
  var isNodeSelected = this.treeElement.tree('isNodeSelected', selectedNode);
  var isNodeAFile = nodeId.indexOf && nodeId.indexOf("file") !== -1;
  
  // We don't bother with folders - only individual files.
  if (isNodeAFile) {
    var indexAfterPrefix = nodeId.indexOf("_") + 1;
    var id = nodeId.slice(indexAfterPrefix);
    
    // <ID, Type, Name, URL>
    if (isNodeSelected) {
      this.treeElement.tree('removeFromSelection', selectedNode);
      
      var tuple = [id, "Material", selectedNode.label, selectedNode.url];
      this.selectedMaterials[id] = tuple;
    } else {
      this.treeElement.tree('addToSelection', selectedNode);
      delete this.selectedMaterials[id];
    }
  }
};