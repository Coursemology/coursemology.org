// Auto-magically referenced. Yay.

$(document).ready(function() {
  var rubyFolders = gon.folders;
  var folders = {};
  
  var currentId = gon.currentFolder.id;
  
  // Convert all the folders to objects.
  rubyFolders.forEach(function(folder) {
    var nameAndCount = folder.name + " (" + folder.count + ")";
    folders[folder.id] = {
      id: folder.id,
      label: nameAndCount,
      url: folder.url,
      parentId: folder.parent_folder_id,
      children: []
    };
  });
  
  
  var treeData = [];
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
  treeData.push(rootFolder);
  
  // Set up the tree.
  var treeElement = $('#file-tree');
  treeElement.tree({
    data: treeData,
    autoOpen: true
  });
  
  // Select the folder we're currently in.
  var currentFolderNode = treeElement.tree('getNodeById', currentId);
  treeElement.tree('selectNode', currentFolderNode);
  
  // Set up bindings on the tree.
  treeElement.bind('tree.select', function(event) {
    var selectedNode = treeElement.tree('getSelectedNode');
    var selectedFolderUrl = selectedNode.url;
    
    window.location.href = selectedFolderUrl;
  });
});