;(function (root) {

  app.config(['$routeProvider', '$locationProvider', 
    function ($routeProvider, $locationProvider) {

      $routeProvider
        .when("/", {
          templateUrl: 'index.html',
          controller: 'FabricVariantIndexCtrl',
          reloadOnSearch: false
        })

      // If using html5 Mode, the router must be configured to ignore
      // missing routes and simply visit them as normal requests.  Not
      // sure if this is the correct way, but it can be done by hooking
      // into redirect and setting window.location
      $locationProvider.html5Mode(true);

      $routeProvider.otherwise({
        redirectTo: function (params, path) {
          window.location = path;
        }
      })
    }]);

})(window);
