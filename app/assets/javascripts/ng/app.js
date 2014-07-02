//= require ./modules

;(function (root) {

  root.app = angular.module('fabrium', [
    'ngRoute', 
    'ngResource',
    'ui.bootstrap',
    'minicolors-ng',
    'selectize-ng'
  ]);

})(window);
