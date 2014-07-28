;(function (root) {

  app.directive('advancedOptions', [function() {
    return {
      restrict : 'C', 
      link : function(scope, element, attrs) {
        // Set up the "advanced fields".  Currently all fields with an ngModel
        // attriubte,  this may have to become more sophisticated if the form 
        // inputs require it
        scope.advanced_fields = _.map(element.find("[ng-model]"), function (el) {
          return $(el).attr("ng-model").replace("search.", "");
        });

        // Set the initial value for the `advanced` var depending on if
        // the initial query includes an advanced param
        scope.advanced = !!_.detect(scope.advanced_fields, function (field) {
          return !!scope.search[field];
        });

        // when toggling the advanced fields off, loop over the advanced
        // params to see if any were included in the query, and if found,
        // update the search.
        scope.$watch("advanced", function (value) {
          if (!value) {
            var deleted = 0;

            angular.forEach(scope.advanced_fields, function (field) {
              if (scope.search[field]) {
                delete scope.search[field];
                deleted++;
              }
            });

            if (deleted) {
              scope.updateSearch();
            }
          }
        });
      }
    };
  }])

  app.controller('FabricVariantShowCtrl',
    ['$scope', '$modalInstance', 'fabric_variant', function ($scope, $modalInstance, fabric_variant) {
      $scope.fabric_variant = fabric_variant;
    }
  ]);

  app.controller('FabricVariantIndexCtrl', 
    ['$scope', '$location', '$timeout', '$modal', 'FabricVariant', 'Tag',
    function ($scope, $location, $timeout, $modal, FabricVariant, Tag) {

      // this will be populated after the form is parsed (see advancedOptions directive)
      $scope.advanced_fields = [];

      $scope.parseSearch = function (search) {
        search || (search = $scope.search);

        // copy the search so as to not reference the original
        search = angular.copy(search);

        // remove undefined/null
        _.compact(search);

        // parse numbers out of numeric form values.
        // TODO find a better way to do this?  A directive??
        var numeric = ["weight_min", "weight_max"];
        _.each(numeric, function (key) {
          if ('undefined' !== typeof search[key]) {
            search[key] = Number(search[key]);
          }
        });

        // If we're on page 1, remove the page from the search and let it
        // default as it's redundant.
        if (1 === search.page) { delete search.page; }

        // Strip the # off the color before applying it to the location.
        // The minicolors has no setting to format this, but oddly it doesn't
        // seem to care if it's there (it probably strips it off itself).
        if (search.color) {
          search.color = search.color.replace(/^#/, "");
        }

        $scope.search = search;
      };

      // init the search scope var from the $location immediately
      $scope.parseSearch($location.search());


      // Sync the scope search with the location search and submit the form.
      //
      // Note that "submitting" the form does not trigger submit, but rather
      // does a reverse sync, updating the location with the form's search
      // state.  This in turn triggers a `$routeUpdate`, which triggers submit.
      // This implementation is so that `popstate` events and form submits
      // both refresh the form in the same way.
      $scope.submit = function () {
        $scope.parseSearch();

        $scope.lastSearch = angular.copy($scope.search);

        $scope.items = FabricVariant.query($scope.search, function (result, headers) {

          var pagination;
          if (pagination = headers('X-Pagination')) {
            $scope.pagination = JSON.parse(pagination);
          } else {
            delete $scope.pagination;
          }

          result.loading = false;
        });

        // set the new result to loading status
        $scope.items.loading = true;
      };


      $scope.updateSearch = function (page) {
        if (page) { $scope.search.page = page; }

        if ($scope.shouldForceSubmit()) {
          $scope.submit();
        } else {
          $location.search(angular.copy($scope.search));
        }
      };

      $scope.shouldForceSubmit = function () {
        $scope.parseSearch();
        return !$scope.lastSearch || 
          angular.equals($scope.lastSearch, $scope.search);
      };

      $scope.$on('$routeUpdate', function () {
        $scope.parseSearch($location.search());
        $scope.submit();
      });

      $scope.selectize = {
        category: {
          sortField: 'text',
          plugins: ['clear_selection']
        },

        material: {
          sortField: 'text',
          plugins: ['clear_selection']
        },

        tags: {
          valueField: 'name',
          labelField: 'name',
					searchField: 'name',
          options: $scope.search.tags
            ? _.map($scope.search.tags.split(","), function(word){ return { name: word }; })
            : [],
          plugins: ['remove_button', 'close_button'],
          load: function (query, callback) {
						if (!query.length) return callback();

            Tag.query({name: query}, function (result) {
              callback(result);
            });
          }
        }
      };

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

      $timeout($scope.submit);
    }
  ]);
})(window);
