var app = require("./app");
require("./controllers");

app.config(['$routeProvider', '$locationProvider', 
  function ($routeProvider, $locationProvider) {
    $locationProvider.html5Mode(true);

    $routeProvider.
      when("/", {
        templateUrl: 'index.html',
        controller: 'FabricIndexCtrl'
      });
  }]);
