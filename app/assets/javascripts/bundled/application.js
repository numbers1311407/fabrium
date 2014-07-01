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

app.controller('FabricVariantShowCtrl',
  ['$scope', '$modalInstance', 'fabric_variant', function ($scope, $modalInstance, fabric_variant) {
    $scope.fabric_variant = fabric_variant;
  }
]);

app.controller('FabricVariantIndexCtrl', 
  ['$scope', '$location', '$modal', 'FabricVariant', 
  function ($scope, $location, $modal, FabricVariant) {

    // Sync the scope search with the location search and submit the form.
    //
    // Note that "submitting" the form does not trigger submit, but rather
    // does a reverse sync, updating the location with the form's search
    // state.  This in turn triggers a `$routeUpdate`, which triggers submit.
    // This implementation is so that `popstate` events and form submits
    // both refresh the form in the same way.
    $scope.submit = function () {
      $scope.search = $location.search();

      $scope.result = FabricVariant.query($scope.search, function (result) {
        $scope.perPage = result.perPage;
        $scope.pages = result.pages;
        $scope.totalItems = result.totalItems;
        $scope.page = result.currentPage;
        result.loading = false;
      });

      // set the new result to loading status
      $scope.result.loading = true;
    };

    $scope.updateForm = function () {
      $scope.search.page = 1;
      $scope.updateLocation();
    };

    $scope.updateLocation = function () {
      if (1 === $scope.search.page) {
        delete $scope.search.page;
      }
      $location.search($scope.search);
    };

    $scope.$on('$routeUpdate', $scope.submit);

    if (!angular.element.isEmptyObject($location.search())) {
      $scope.submit();
    }

    $scope.show = function (id) {
      var modalInstance = $modal.open({
        templateUrl: "show.html",
        controller: "FabricVariantShowCtrl",
        resolve: {
          fabric_variant: function () {
            return FabricVariant.get({id: id});
          }
        }
      })
    };
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

app.factory('FabricVariant', ['$resource', 
  function($resource){
    return $resource('fabric_variants/:id.json', {}, {
      query: {method:'GET', url: 'fabric_variants.json'}
    });
  }]);

},{"./app":2}],7:[function(require,module,exports){
var app = require("./app");

app.config(['$routeProvider', '$locationProvider', 
  function ($routeProvider, $locationProvider) {
    $locationProvider.html5Mode(true);

    $routeProvider.
      when("/", {
        templateUrl: 'index.html',
        controller: 'FabricVariantIndexCtrl',
        reloadOnSearch: false
      });
  }]);

},{"./app":2}]},{},[1])