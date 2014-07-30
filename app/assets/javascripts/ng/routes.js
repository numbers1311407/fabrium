;(function (root) {

  app.config(function ($routeProvider, $locationProvider) {
    $routeProvider
      .when("/", {
        templateUrl: '/templates/fabric_variants/index',
        controller: 'FabricVariantIndexCtrl',
        reloadOnSearch: false
      })
    ;

    $locationProvider.html5Mode(true);
  });

})(window);
