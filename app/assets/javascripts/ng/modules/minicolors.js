;(function (root) {

  var module = angular.module('minicolors-ng', []);

  module.directive('minicolors', [function () {
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

        // turn off HTML5 spell checking
        element.attr("spellcheck", false);

        element.minicolors(getSettings());
      }
    };
  }]);

})(window);
