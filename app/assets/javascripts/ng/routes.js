var app = require("./app");

app.config(['$routeProvider', '$locationProvider', 
  function ($routeProvider, $locationProvider) {
    $locationProvider.html5Mode(true);

    $routeProvider.
      when("/", {
        templateUrl: 'index.html',
        controller: 'FabricVariantIndexCtrl',
        reloadOnSearch: false
      });
  }]);
