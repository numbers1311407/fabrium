;(function (root) {

  var module = angular.module('minicolors-ng', []);

  module.directive('minicolors', [function () {
    return {
      restrict: 'A',
      link: function(scope, element, attrs, ngModel) {
        var getSettings = function () {
          return angular.extend({}, $.minicolors.defaults, scope.$eval(attrs.minicolors));
        };

        // change the input's color on changes to the model which happen
        // outside the input control
        scope.$watch(attrs.ngModel, function (value) {
          // Note the value must be set to an empty string to reset the
          // color swatch, setting it to undefined will remove the hex string
          // but not change the color of the swatch in the field.
          element.minicolors('value', value || "");
        });

        // if the settings change, update minicolors (this is unlikely)
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
