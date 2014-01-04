var coursemologyApp = angular.module('coursemologyApp', ['ngResource', 'ngRoute', 'ui.sortable']);

coursemologyApp.config(function($httpProvider){
    var authToken;
    authToken = $("meta[name=\"csrf-token\"]").attr("content");
    return $httpProvider.defaults.headers.common["X-CSRF-TOKEN"] = authToken;
});

coursemologyApp.config(function($locationProvider){
//    $locationProvider
//        .html5Mode(false)
//        .hashPrefix('!');
//        $locationProvider.html5Mode(true);
});