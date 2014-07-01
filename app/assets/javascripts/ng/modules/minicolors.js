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
