//= require angular/angular
//= require angular-route/angular-route
//= require angular-bootstrap/ui-bootstrap-tpls
//= require angular-cache/dist/angular-cache
//= require restangular/dist/restangular
//= require jquery-cycle2/build/jquery.cycle2
//= require jquery-cycle2/src/jquery.cycle2.carousel
//= require jquery-cycle2/src/jquery.cycle2.center
//= require ./ng

// tweak cycle's templating so as not to interfere with angular
$.extend($.fn.cycle.defaults, {
  tmplRegex: '@@((.)?.*?)@@'
});
