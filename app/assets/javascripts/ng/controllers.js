;(function (root) {
  var autosave_timeout = 1000 * 10;

  app.controller('FabricVariantIndexCtrl', 
    function ($scope, $location, $timeout, $modal, Restangular, RestangularWithResponse) {

      // On load get the current user
      Restangular.oneUrl("users", "/profile.json").get().then(function (user) {
        $scope.current_user = user;

        // Get the pending cart unless the user is an Admin, who doesn't
        // have one
        if (!user.isAdmin()) {

          // This defies expectation a bit, but the way Restangular works,
          // it does not update existing "models" as you might think.  There
          // may be a way to do this but it was not obvious.  As such the
          // scope's `cart` is created initially (in the case that the user
          // does not have a pending cart available)...
          $scope.cart = Restangular.one("cart");

          // ... and then replaces itself via a `get` if the request does 
          // not 404.
          $scope.cart.get().then(function (cart) {
            $scope.cart.variant_ids = cart.variant_ids;
          });

          $scope.$watch("cart.size()", function (v) {
            $("a.cart-link .count").text(v);
          });
        }
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

      $scope.isFavorite = function (n) {
        return !!$scope.current_user.favorites[n];
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

        // $scope.hideSearch();

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
              return Restangular.one("fabrics", id).get();
            }
          }
        })
      };

      if (!_.isEmpty($scope.search)) {
        $timeout($scope.submit);
      }
    }
  );

  app.controller('FabricShowCtrl',
    function ($scope, $modalInstance, Restangular, resource) {
      $scope.resource = resource;

      $scope.$watch("position", function (val) {
        $scope.variant = resource.variants[val];
      });

      $scope.printModal = function () {
        var $el = $(".ng-modal .modal-dialog");
        utils.printElement($el[0]);
        window.print();
      };

      /**
       * Super kludgy note implementation.
       *
       * Could use a refactor!
       *
       * The double flag approach of saving & dirty is necessitated by
       * the throttled execution of the update request itself and then
       * the time of the request.
       *
       * The note should save every X seconds while the modal is opened,
       * but if the modal closes it needs to save immediately.  If the
       * modal closes while in the middle of a throttled delay, the throttled
       * request will not occur because the note is already either saving
       * or has been cleaned.
       */

      // note tracks the note itself, it's "dirty" state, and whether
      // it's currently enroute to save
      $scope.note = {note: null, dirty: false, saving: false};

      // note updating function
      var updateNote = function () {
        // if the note isn't dirty, or if it's already saving, return
        if (!$scope.note.dirty || $scope.note.saving) {
          return;
        }
        // mark it as saving (or deleting, whatevs)
        $scope.note.saving = true;

        var note = $scope.note.note, promise;

        // then make the request based on note's contents
        if (note) {
          var req = Restangular.one("fabric_notes", resource.id);
          req.note = note;
          promise = req.put();
        } else {
          promise = Restangular.one("fabric_notes", resource.id).remove();
        }

        promise.then(function () {
          $scope.note.dirty = false;
          $scope.note.saving = false;
        });
      }

      // throttled note updater for changes to the text area
      var throttledUpdate = _.throttle(updateNote, autosave_timeout, {leading: false});

      // Call update immediately on close.  This will only result in
      // a request if the note has been changed.
      $modalInstance.result.finally(updateNote);

      // As the note changes, set the note as dirty then queue up the 
      // throttled update.  It will execute after N seconds or whenever
      // the modal is closed.
      $scope.$watch('note.note', function (note, oldnote) {
        // On the initial server response the note will change from null.
        // Don't respond to this with a persistence request.
        if (null !== oldnote) {
          $scope.note.dirty = true;
          throttledUpdate(note);
        }
      });

      $scope.onCycleBefore = function (e, API) {
        $scope.position = API.nextSlide;
      };

      Restangular.one("fabric_notes", resource.id).get().then(function (note) {
        $scope.note.note = note.note;
      });
    }
  );
})(window);
