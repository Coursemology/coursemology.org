// Auto-magically referenced. Yay.

$(document).ready(function() {
  var rootNode = gon.folders;
  if (!rootNode) {
      return;
  }

  var folders = {};
  var currentId = gon.currentFolder.id;
  
  // Convert all the folders to tree nodes.
  var foldersToProcess = [rootNode];
  while (foldersToProcess.length) {
    var currentFolder = foldersToProcess.shift();
    if (currentFolder.subfolders) {
      for (var i = 0; i < currentFolder.subfolders.length; i++) {
        foldersToProcess.push(currentFolder.subfolders[i]);
      }
    }
    
    var count = currentFolder.files ? currentFolder.files.length : 0;
    
    var nameAndCount = currentFolder.name + " (" + count + ")";
    folders[currentFolder.id] = {
      id: currentFolder.id,
      label: nameAndCount,
      url: currentFolder.url,
      parentId: currentFolder.parent_folder_id,
      children: []
    }
  }  
  
  var rootFolder;
  
  // Generate the tree we need for jqTree.
  for (var id in folders) {
    var folder = folders[id];
    var parentId = folder.parentId;
    if (!parentId) {
      rootFolder = folder;
    } else {
      folders[parentId].children.push(folder);
    }
  }
  var treeData = [rootFolder];
  
  // Set up the tree.
  var treeElement = $('#file-tree');
  treeElement.tree({
    data: treeData,
    autoOpen: true,
    keyboardSupport: false
  });
  
  // Select the folder we're currently in.
  var currentFolderNode = treeElement.tree('getNodeById', currentId);
  treeElement.tree('selectNode', currentFolderNode);
  
  // Set up bindings on the tree.
  treeElement.bind('tree.select', function(event) {
    var selectedNode = event.node;
    if (selectedNode) {
      var selectedFolderUrl = selectedNode.url;
      window.location.href = selectedFolderUrl;
    }
  });
});