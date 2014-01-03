//angular.module('coursemologyApp').controller("TabCtrl", function($scope, $timeout, $routeParams, Tab) {
//    var lowerPrioritiesBelow, raisePriorities, serverErrorHandler, tasksBelow, updatePriorities;
//    $scope.sortMethod = 'order';
//    $scope.sortableEnabled = true;
//    $scope.init = function() {
//        this.tabService = new Tab($routeParams.list_id, serverErrorHandler);
//        return $scope.list = this.listService.find($routeParams.list_id);
//    };
//    $scope.addTask = function() {
//        var task;
//        task = this.tabService.create({
//            description: $scope.taskDescription
//        });
//        task.priority = 1;
//        $scope.list.tasks.unshift(task);
//        return $scope.taskDescription = "";
//    };
//    $scope.deleteTask = function(task) {
//        this.tabService["delete"](task);
//        return $scope.list.tasks.splice($scope.list.tasks.indexOf(task), 1);
//    };
//    $scope.toggleTask = function(task) {
//        return this.tabService.update(task, {
//            completed: task.completed
//        });
//    };
//    $scope.listNameEdited = function(listName) {
//        return this.listService.update(this.list, {
//            name: listName
//        });
//    };
//    $scope.taskEdited = function(task) {
//        return this.tabService.update(task, {
//            description: task.description
//        });
//    };
//    $scope.dueDatePicked = function(task) {
//        return this.tabService.update(task, {
//            due_date: task.due_date
//        });
//    };
//    $scope.priorityChanged = function(task) {
//        this.tabService.update(task, {
//            target_priority: task.priority
//        });
//        return updatePriorities();
//    };
//    $scope.sortableOptions = {
//        update: function(e, ui) {
//            var domIndexOf, newPriority, task;
//            domIndexOf = function(e) {
//                return e.siblings().andSelf().index(e);
//            };
//            newPriority = domIndexOf(ui.item) + 1;
//            task = ui.item.scope().task;
//            task.priority = newPriority;
//            return $scope.priorityChanged(task);
//        }
//    };
//    $scope.changeSortMethod = function(sortMethod) {
//        $scope.sortMethod = sortMethod;
//        if (sortMethod === 'priority') {
//            return $scope.sortableEnabled = true;
//        } else {
//            return $scope.sortableEnabled = false;
//        }
//    };
//    $scope.dueDateNullLast = function(task) {
//        var _ref;
//        return (_ref = task.due_date) != null ? _ref : '2999-12-31';
//    };
//    serverErrorHandler = function() {
//        return alert("There was a server error, please reload the page and try again.");
//    };
////    updatePriorities = function() {
////        return $timeout(function() {
////            return angular.forEach($scope.list.tasks, function(task, index) {
////                return task.priority = index + 1;
////            });
////        });
////    };
////    raisePriorities = function() {
////        return angular.forEach($scope.list.tasks, function(t) {
////            return t.priority += 1;
////        });
////    };
////    lowerPrioritiesBelow = function(task) {
////        return angular.forEach(tasksBelow(task), function(t) {
////            return t.priority -= 1;
////        });
////    };
//    return tasksBelow = function(task) {
//        return $scope.list.tasks.slice($scope.list.tasks.indexOf(task), $scope.list.tasks.length);
//    };
//});