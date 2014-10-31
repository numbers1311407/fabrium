;(function (root) {

  function isInteger(str) {
    var n = ~~Number(str);
    return String(n) === str && n >= 0;
  }

  app.controller('FabricVariantIndexCtrl', 
    function ($scope, $location, $timeout, $modal, Restangular, RestangularWithResponse, fabrics, currentUser) {


      function serializeSearch (search) {
        search = (search || angular.copy($scope.search));
        _.each(searchSerializers, function (fn, key) {
          if ('undefined' !== typeof search[key]) { search[key] = fn(search[key]); }
        });
        return search;
      }

      var searchDeserializers = {
        materials: function (value) {
          var split, id, min, max, name;
          return _.reduce(value.split(','), function (m, val) {
            split = val.split(':');
            name = split[0];
            id = parseInt(split[1], 10);
            if (!isNaN(id) && name) {
              min = isInteger(split[2]) ? Number(split[2]) : undefined;
              max = isInteger(split[3]) ? Number(split[3]) : undefined;
              m.push({id: id, name: name, min: min, max: max});
            }
            return m;
          }, []);
        }
      };

      var searchSerializers = {
        materials: function (array) {
          return array.map(function (o) {
            return [escape(o.name), o.id, o.min, o.max].join(':');
          }).join(",");
        }
      };

      currentUser.get().then(function (user) {
        $scope.currentUser = user;

        if (user) user.getCart().then(function (cart) {
          if (!cart) return;

          $scope.cart = cart;
          $scope.$watch("cart.size()", function (v) {
            $("a.cart-link .count").text(v);
          });
        });
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

      $scope.parseSearch = function (search, deserialize) {
        search || (search = $scope.search);

        // copy the search so as to not reference the original
        search = angular.copy(search);

        // if deserializing (from the location string) run any registered
        // deserializers
        if (deserialize) {
          _.each(searchDeserializers, function (fn, key) {
            if ('undefined' !== typeof search[key]) { search[key] = fn(search[key]); }
          });
        }

        // remove undefined/null
        _.compact(search);


        // delete empty arrays
        _.each(search, function (value, key) {
          if (Array.isArray(value) && !value.length) {
            delete search[key]; 
          }
        });


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


      $scope.hideSearch = function () {
        var $main = angular.element("#main");
        var $searchFooter = angular.element("#main .search-footer");
        var $navbar = angular.element("#navbar-main");
        var $searchPanel = angular.element("#search-panel");
        var height = $searchPanel.height() - $searchFooter.outerHeight() - 13;

        $scope.searchHidden = true;
        $main.css({top: -height});
      };

      $scope.showSearch = function (e) {
        e.preventDefault();
        var $main = angular.element("#main");
        $scope.searchHidden = false;
        $main.css({top: 0});
      };


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

        var search = angular.copy($scope.search);

        // $scope.hideSearch();

        // NOTE Is this needed?  Does the index cache?
        // $scope.search._ = Date.now();

        items.getList(serializeSearch(search))
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
          $location.search(serializeSearch());
        }
      };

      $scope.lastSearch = {};

      $scope.shouldForceSubmit = function () {
        $scope.parseSearch();

        return angular.equals($scope.lastSearch, $scope.search);
      };

      $scope.$on('$routeUpdate', function () {
        $scope.parseSearch($location.search(), true);
        $scope.submit();
      });


      $scope.removeMaterial = function (id) {
        if (!$scope.search.materials) { return; }
        var i = 0, found = false;
        for (;i < $scope.search.materials.length; i++) {
          if ($scope.search.materials[i].id == id) {
            found = true;
            break;
          }
        }
        if (found) { $scope.search.materials.splice(i, 1); }
      };


      $scope.selectize = {
        category: {
          sortField: 'text',
          plugins: ['clear_selection']
        },

        material: {
          valueField: 'id',
          labelField: 'name',
          searchField: 'name',
          plugins: ['lazy_preload'],
          onInitialize: function () {
            var api = this;

            this.on("item_add", function (value, $item) {
              $scope.search.materials || ($scope.search.materials = []);

              var existing = _.find($scope.search.materials, function (mat) {
                return mat.id == value;
              });

              if (!existing) {
                $scope.search.materials.push({
                  id: value,
                  name: $item.html()
                });
              }

              api.clear();
            });
          },
          load: function (query, callback) {
            var args = query.length ? {name: query} : {};
            Restangular.all("materials").getList(args).then(callback);
          }
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
          plugins: {
            remove_button: {},
            close_button: {},
            open_placeholder: {
              placeholder: "Type to search mills by name..."
            }
          },
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
          plugins: ['remove_button', 'close_button', 'lazy_preload'],
          onInitialize: function () {
            var tags = $scope.search.tags
              ? _.map($scope.search.tags.split(","), function(word){ return { name: word }; })
              : [];
            this.addOption(tags);
          },
          load: function (query, callback) {
            var args = query.length ? {name: query} : {};
            Restangular.all("tags").getList(args).then(callback);
          }
        }
      };

      $scope.show = function (id, position) {
        var modalInstance = $modal.open({
          templateUrl: "/templates/fabrics/show",
          controller: "FabricShowCtrl",
          windowClass: "ng-modal",
          // scope: $scope,
          resolve: {
            modal: function () {
              return $modal;
            },
            position: function () {
              return position;
            },
            fabric: function () {
              return fabrics.get(id);
            }
          }
        });
      };

      // init the search scope var from the $location immediately
      $scope.parseSearch($location.search(), true);

      if (!_.isEmpty($scope.search)) {
        $timeout($scope.submit);
      }
    }
  );

  app.controller('FabricShowCtrl', function ($scope, $location, $modalInstance, fabric, position, currentUser) {
    $scope.fabric = fabric;
    $scope.isModal = !!$modalInstance;

    currentUser.get().then(function (user) {
      $scope.currentUser = user;

      if (user) user.getCart().then(function (cart) {
        if (!cart) return;

        $scope.cart = cart;
        $scope.$watch("cart.size()", function (v) {
          $("a.cart-link .count").text(v);
        });
      });
    });

    if ($modalInstance) {
      $scope.close = function () {
        $modalInstance.dismiss();
      };
    }

    /**
     * Provide a cycling hook for jQuery Cycle to change the
     * current fabric variant as the slides change.
     */

    $scope.$watch("position", function (val) {
      $scope.variant = fabric.variants[val];
    });

    $scope.setPosition = function (position) {
      if (/^\d+$/.test(position) && parseInt(position, 0) < fabric.variants.length) {
        $scope.position = parseInt(position, 0);
      } else {
        $scope.position = 0;
      }
    };

    $scope.setPosition(position);

    $scope.$on('$routeUpdate', function () {
      $scope.setPosition($location.search().v);
    });

    $scope.handleRequestClick = function (id) {
      if ($scope.cart.hasItem(id)) {
        location.href = "/cart";
      } else {
        $scope.cart.toggleItem(id);
      }
    };


    /**
     * "Print screen" function
     * TODO needs work
     */

    $scope.print = function () {
      var $el = $(".fabrics-show");
      utils.printElement($el[0]);
      window.print();
    };
  });

})(window);
