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
          // NOTE we pass a null modalInstance here so that the same controller
          // can be used for both modal and non-modal fabric views
          $modalInstance: function () {
            return null;
          },
          position: function ($route, $location) {
            return $location.search().v || 0;
          },
          fabric: function ($route, fabrics) {
            return fabrics.get($route.current.params.id);
          }
        },
        reloadOnSearch: false
      })
    ;

    $locationProvider.html5Mode(true);
  });

  // surely not the place for this.
  app.run(function ($rootScope, $location) {
    $rootScope.location = $location;
  });

})(window);
