(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);throw new Error("Cannot find module '"+o+"'")}var f=n[o]={exports:{}};t[o][0].call(f.exports,function(e){var n=t[o][1][e];return s(n?n:e)},f,f.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
require("./ng");

},{"./ng":4}],2:[function(require,module,exports){
var minicolors = require("./modules/minicolors");

// exports
var app = module.exports = angular.module('fabrium', [
  'ngRoute', 
  'ngResource',
  'ui.bootstrap',
  'minicolors'
]);

},{"./modules/minicolors":5}],3:[function(require,module,exports){
var app = require("./app")
  , resources = require("./resources");

app.controller('FabricShowCtrl',
  ['$scope', '$modalInstance', 'fabric', function ($scope, $modalInstance, fabric) {
    $scope.fabric = fabric;
  }
]);

app.controller('FabricIndexCtrl', 
  ['$scope', '$location', '$modal', 'Fabric', function ($scope, $location, $modal, Fabric) {

    $scope.query = {
      keywords: "foo bar baz"
    };

    $scope.search = function () {
      $scope.fabrics = Fabric.query($scope.query);
    };

    $scope.show = function (id) {
      var modalInstance = $modal.open({
        templateUrl: "show.html",
        controller: "FabricShowCtrl",
        resolve: {
          fabric: function () {
            return Fabric.get({id: id});
          }
        }
      })
    };

    $scope.search();
  }
]);

},{"./app":2,"./resources":6}],4:[function(require,module,exports){
require("./app");
require("./routes");
require("./controllers");

},{"./app":2,"./controllers":3,"./routes":7}],5:[function(require,module,exports){
module.exports = angular.module('minicolors', []);

module.exports.directive('minicolors', [function () {
  return {
    restrict: 'A',
    link: function(scope, element, attrs, ngModel) {
      var getSettings = function () {
        return angular.extend({}, $.minicolors.defaults, scope.$eval(attrs.minicolors));
      };

      scope.$watch(attrs.ngModel, function (value) {
        element.minicolors('value', value);
      });

      scope.$watch(getSettings, function (settings) {
        element.minicolors("settings", settings);
      }, true);

      element.minicolors(getSettings());
    }
  };
}]);

},{}],6:[function(require,module,exports){
var app = require("./app");

app.factory('Fabric', ['$resource', 
  function($resource){
    return $resource('fabrics/:id.json', {}, {
      query: {method:'GET', url: 'fabrics.json', isArray: true}
    });
  }]);

},{"./app":2}],7:[function(require,module,exports){
var app = require("./app");
require("./controllers");

app.config(['$routeProvider', '$locationProvider', 
  function ($routeProvider, $locationProvider) {
    $locationProvider.html5Mode(true);

    $routeProvider.
      when("/", {
        templateUrl: 'index.html',
        controller: 'FabricIndexCtrl'
      });
  }]);

},{"./app":2,"./controllers":3}]},{},[1])