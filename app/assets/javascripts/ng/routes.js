;(function (root) {

  app.config(function ($routeProvider, $locationProvider) {

    $routeProvider
      .when("/", {
        templateUrl: '/templates/fabric_variants/index',
        controller: 'FabricVariantIndexCtrl',
        reloadOnSearch: false
      })

      .when("/fabrics/:id", {
        templateUrl: '/templates/fabrics/show',
        controller: 'FabricShowCtrl',
        resolve: {
          position: function ($route, $location) {
            var hash = $location.hash();
            // eh.
            return hash.match(/^\d+$/) && hash || 0;
          },
          fabric: function ($route, fabrics) {
            return fabrics.get($route.current.params.id);
          }
        }
      })
    ;

    $locationProvider.html5Mode(true);
  });

})(window);
