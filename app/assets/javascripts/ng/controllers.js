;(function (root) {

  app.controller('FabricVariantShowCtrl',
    ['$scope', '$modalInstance', 'fabric_variant', function ($scope, $modalInstance, fabric_variant) {
      $scope.fabric_variant = fabric_variant;
    }
  ]);

  app.controller('FabricVariantIndexCtrl', 
    ['$scope', '$location', '$modal', 'FabricVariant', 
    function ($scope, $location, $modal, FabricVariant) {

      // Sync the scope search with the location search and submit the form.
      //
      // Note that "submitting" the form does not trigger submit, but rather
      // does a reverse sync, updating the location with the form's search
      // state.  This in turn triggers a `$routeUpdate`, which triggers submit.
      // This implementation is so that `popstate` events and form submits
      // both refresh the form in the same way.
      $scope.submit = function () {
        $scope.search = $location.search();

        $scope.result = FabricVariant.query($scope.search, function (result) {
          $scope.perPage = result.perPage;
          $scope.pages = result.pages;
          $scope.totalItems = result.totalItems;
          $scope.page = result.currentPage;
          result.loading = false;
        });

        // set the new result to loading status
        $scope.result.loading = true;
      };

      $scope.updateForm = function () {
        $scope.search.page = 1;
        $scope.updateLocation();
      };

      $scope.updateLocation = function () {
        if (1 === $scope.search.page) {
          delete $scope.search.page;
        }
        $location.search($scope.search);
      };

      $scope.$on('$routeUpdate', $scope.submit);

      if (!angular.element.isEmptyObject($location.search())) {
        $scope.submit();
      }

      $scope.show = function (id) {
        var modalInstance = $modal.open({
          templateUrl: "show.html",
          controller: "FabricVariantShowCtrl",
          resolve: {
            fabric_variant: function () {
              return FabricVariant.get({id: id});
            }
          }
        })
      };
    }
  ]);
})(window);
