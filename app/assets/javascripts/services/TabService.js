angular.module('coursemologyApp').factory('Tab', function($resource, $http) {
    var Tab;
    return Tab = (function() {
        function Tab(id, errorHandler) {
            var defaults;
            this.service = $resource('/tabs/:id', {
                id: '@id'
            }, {
                update: {
                    method: 'PUT'
                }
            });
            this.errorHandler = errorHandler;
            defaults = $http.defaults.headers;
            defaults.patch = defaults.patch || {};
            defaults.patch['Content-Type'] = 'application/json';
        }

        Tab.prototype.create = function(attrs) {
            new this.service({
                tab: attrs
            }).$save((function(tab) {
                    return attrs.id = tab.id;
                }), this.errorHandler);
            return attrs;
        };

        Tab.prototype["delete"] = function(tab) {
            return new this.service().$delete({
                id: tab.id
            }, (function() {
                return null;
            }), this.errorHandler);
        };

        Tab.prototype.update = function(tab, attrs) {
            return new this.service({
                tab: attrs
            }).$update({
                    id: tab.id
                }, (function() {
                return null;
            }), this.errorHandler);
        };

        Tab.prototype.all = function() {
            return this.service.query((function() {
                return null;
            }), this.errorHandler);
        };
        return Tab;
    })();
});