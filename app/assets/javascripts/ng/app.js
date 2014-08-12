//= require ./modules

;(function (root) {

  root.app = angular.module('fabrium', [
    'ngRoute', 
    'ui.bootstrap',
    'minicolors-ng',
    'alerts-ng',
    'selectize-ng',
    'restangular',
    'angular-data.DSCacheFactory'
  ]);

})(window);
