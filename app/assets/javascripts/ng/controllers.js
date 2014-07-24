;(function (root) {

  app.controller('FabricVariantShowCtrl',
    ['$scope', '$modalInstance', 'fabric_variant', function ($scope, $modalInstance, fabric_variant) {
      $scope.fabric_variant = fabric_variant;
    }
  ]);

  app.controller('FabricVariantIndexCtrl', 
    ['$scope', '$location', '$modal', 'FabricVariant', 'properties',
    function ($scope, $location, $modal, FabricVariant, properties) {

      $scope.selectize = {
        category: {
          sortField: 'text',
          plugins: ['clear_selection']
        },

        fiber_content: {
          sortField: 'text',
          plugins: ['clear_selection']
        },

        keywords: {
          valueField: 'id',
          labelField: 'name',
					searchField: 'name',
          plugins: ['remove_button', 'close_button'],
          load: function (query, callback) {
						if (!query.length) return callback();
            properties.fetch('keywords', {name: query})
              .then(function (result) {
                callback(result);
              });
          }
        }
      };


      // Sync the scope search with the location search and submit the form.
      //
      // Note that "submitting" the form does not trigger submit, but rather
      // does a reverse sync, updating the location with the form's search
      // state.  This in turn triggers a `$routeUpdate`, which triggers submit.
      // This implementation is so that `popstate` events and form submits
      // both refresh the form in the same way.
      $scope.submit = function () {
        $scope.search = $location.search();

        $scope.items = FabricVariant.query($scope.search, function (result) {
          // $scope.perPage = result.perPage;
          // $scope.pages = result.pages;
          // $scope.totalItems = result.totalItems;
          // $scope.page = result.currentPage;
          result.loading = false;
        });

        // set the new result to loading status
        $scope.items.loading = true;
      };

      $scope.updateForm = function () {
        $scope.search.page = 1;
        $scope.updateLocation();
      };

      $scope.updateLocation = function () {
        if (!$scope.search.category) {
          delete $scope.search.category;
        }

        if (!$scope.search.fiber_content) {
          delete $scope.search.fiber_content;
        }

        if (!$scope.search.weight_unit) {
          delete $scope.search.weight_unit;
        }

        // If we're on page 1, remove the page from the search and let it
        // default as it's redundant.
        if (1 === $scope.search.page) {
          delete $scope.search.page;
        }
        // Strip the # off the color before applying it to the location.
        // The minicolors has no setting to format this, but oddly it doesn't
        // seem to care if it's there (it probably strips it off itself).
        if ($scope.search.color) {
          $scope.search.color = $scope.search.color.replace(/^#/, "");
        }
        $location.search($scope.search);
      };

      $scope.$on('$routeUpdate', $scope.submit);

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

      if (!angular.element.isEmptyObject($location.search())) {
        $scope.submit();
      }
    }
  ]);
})(window);
