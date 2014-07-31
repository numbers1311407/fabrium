;(function (root) {

  app.controller('FabricShowCtrl',
    function ($scope, $modalInstance, resource) {
      $scope.resource = resource;

      $scope.printModal = function () {
        var $el = $(".ng-modal .modal-dialog");
        utils.printElement($el[0]);
        window.print();
      }
    }
  );

  app.controller('FabricVariantIndexCtrl', 
    function ($scope, $location, $timeout, $modal, Restangular, RestangularWithResponse) {

      Restangular.oneUrl("users", "/profile.json").get().then(function (user) {
        $scope.current_user = user;
      });

      $scope.mill_options = {};
      $scope.mill_cache = {};
      $scope.load_mill_options = function (mill_ids) {
        var cache = function () {
          $scope.mill_options.values = _.map($scope.mill_cache, _.identity);
        }
        var ids = _.reduce(mill_ids, function (ids, id) {
          if (!$scope.mill_cache[id]) { ids.push(id); }
          return ids;
        }, []);

        if (ids.length) {
          Restangular.all("mills").getList({id: ids.join(",")}).then(function (results) {
            angular.forEach(results, function (result) {
              $scope.mill_cache[result.id] = result;
            });
            cache();
          });
        } else {
          // kludgy hack to make the mill_options change
          $scope.mill_options.values = [];
          $timeout(cache);
        }
      };

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
        var numeric = [
          "weight_min", 
          "weight_max",
          "price_min",
          "price_max",
          "bulk_min",
          "sample_min"
        ];
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

        $scope.current_page_height = 
            angular.element(".fabric-variant-resultlist").height();

        $scope.lastSearch = angular.copy($scope.search);

        var items = RestangularWithResponse.all("fabric_variants");

        items.getList($scope.search)
          .then(function (res) {
            $scope.items = res.data;
            var pagination;
            if (pagination = res.headers('X-Pagination')) {
              $scope.pagination = JSON.parse(pagination);
            } else {
              delete $scope.pagination;
            }
          })
          .finally(function () {
            $scope.loading = false;
          });

        // set the new result to loading status
        $scope.loading = true;
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

        country: {
          sortField: 'text',
          plugins: ['clear_selection']
        },

        weeks: {
          plugins: ['clear_selection']
        },

        dye_method: {
          sortField: 'text',
          plugins: ['clear_selection']
        },

        mills: {
          valueField: 'id',
          labelField: 'name',
          searchField: 'name',
          plugins: ['remove_button', 'close_button'],
          onInitialize: function () {
            this.on("invalid_values", $scope.load_mill_options);
          },
          load: function (query, callback) {
            if (!query.length) { return callback(); }
            Restangular.all("mills").getList({name: query}).then(callback);
          }

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
            Restangular.all("tags").getList({name: query}).then(callback);
          }
        }
      };

      $scope.show = function (id, position) {

        $scope.position = position;

        var modalInstance = $modal.open({
          templateUrl: "/templates/fabrics/show",
          controller: "FabricShowCtrl",
          windowClass: "ng-modal",
          scope: $scope,
          resolve: {
            resource: function () {
              // resolve accepts promises and resolves them!
              return Restangular.one("fabrics", id).get();
            }
          }
        })
      };

      $timeout($scope.submit);
    }
  );

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
})(window);
