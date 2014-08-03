;(function () {
  app.config(function (RestangularProvider) {
    /**
     * Let's be clear about the JSON, given that this is a responder Rails
     * API that also handles the HTML views.
     */
    RestangularProvider.setRequestSuffix('.json');

    /**
     * An interceptor for CREATE/UPDATE requests to conform to the typical
     * Rails way of wrapping params via an instance name.
     *
     * The "singularization" necessary here is extremely rudimentary and
     * dependent on the domain.  Robust, this clearly is not.
     */
    RestangularProvider.addRequestInterceptor(function (el, op, what, url) {
      if (el && ('put' == op || 'post' == op)) {

        // The MOST ABSOLUTELY rudimentary singularization, which ends up
        // being fine for our domain (but... could cause some frustration
        // probably if a model was added for `Goose` or the like.
        var name = what.replace(/s$/, '');
        var payload = el;
        var el = {};
        el[name] = payload;
      }

      return el;
    });


    RestangularProvider.setErrorInterceptor(function(response, deferred, responseHandler) {
      if (response.status === 401) {
        utils.log.error("Your session has expired, please log in again.");
        return false; // error handled
      }

      return true; // error not handled
    });
  });


  /**
   * This gives us access to headers.  Use case is to retrieve pagination
   * headers which come back with collections.
   */
  app.factory('RestangularWithResponse', function(Restangular) {
    return Restangular.withConfig(function(RestangularConfigurer) {
      RestangularConfigurer.setFullResponse(true);
    });
  });
})();
