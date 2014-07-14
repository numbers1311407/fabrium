//= require ./modules

;(function (root) {

  root.app = angular.module('fabrium', [
    'ngRoute', 
    'ngResource',
    'ui.bootstrap',
    'minicolors-ng',
    'alerts-ng',
    'selectize-ng'
  ]);

})(window);
