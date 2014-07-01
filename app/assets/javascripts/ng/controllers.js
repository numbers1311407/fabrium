var app = require("./app")
  , resources = require("./resources");

app.controller('FabricShowCtrl',
  ['$scope', '$modalInstance', 'fabric', function ($scope, $modalInstance, fabric) {
    $scope.fabric = fabric;
  }
]);

app.controller('FabricIndexCtrl', 
  ['$scope', '$location', '$modal', 'Fabric', function ($scope, $location, $modal, Fabric) {

    $scope.query = {
      keywords: "foo bar baz"
    };

    $scope.search = function () {
      $scope.fabrics = Fabric.query($scope.query);
    };

    $scope.show = function (id) {
      var modalInstance = $modal.open({
        templateUrl: "show.html",
        controller: "FabricShowCtrl",
        resolve: {
          fabric: function () {
            return Fabric.get({id: id});
          }
        }
      })
    };

    $scope.search();
  }
]);
