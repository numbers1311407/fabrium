;(function () {
  app.config(function (RestangularProvider) {
    RestangularProvider.setRequestSuffix('.json');
  });

  app.factory('RestangularWithResponse', function(Restangular) {
    return Restangular.withConfig(function(RestangularConfigurer) {
      RestangularConfigurer.setFullResponse(true);
    });
  });
})();
