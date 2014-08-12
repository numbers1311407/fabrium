;(function (root) {

  /**
   * Directive to handle partitioning the "advanced search options" for
   * the fabric search.
   *
   * The directive will scrub the search param for advanced fields and rerun
   * the search automatically if the advanced fields are closed.
   *
   * The advanced fields are parsed out of the HTML by finding all elements
   * in the advanced field container with an `ngModel`.  This may need to
   * change if other fields inside the container need to track a model.
   */
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

  app.directive('a', function() {
    return {
      restrict: 'E',
      link: function(scope, elem, attrs) {
        if (attrs.ngClick) {
          elem.on('click', function(e) {
            e.preventDefault();
          });
        }
      }
    };
  });


  app.directive('cycle', function ($timeout) {

    return {
      restrict: 'A',
      scope: {
        before: "=onCycleBefore"
      },
      link: function (scope, elem, attrs) {
        // timeout to come in after the ng-repeat
        $timeout(function () {
          $(elem).cycle();

          if (scope.before) {
            $(elem).on("cycle-before", scope.before);
          }
        });

        scope.$on('$destroy', function() {
          $(elem).cycle('destroy');
        });
      }
    }
  });


  app.directive('fabricNotesFor', function (Restangular, $timeout) {
    // autosave every N seconds (saving will happen immediately on modal
    // close, if a change occurred)
    var autosave_timeout = 10 * 1000;

    return {
      restrict: 'A',
      scope: {
        fabricNotesFor: '='
      },

      link: function(scope, element, attrs) {
        var fabric = scope.fabric = scope.fabricNotesFor;
        var id = fabric.id;
        var dirty = false;
        var transit = false;

        // note updating function
        var update = scope.updateNote = function () {

          // if the note isn't dirty, or if it's already transit, return
          if (!dirty || transit) {
            return;
          }

          // mark it as in transit
          transit = true;

          var promise;

          // then make the request based on note's contents
          if (fabric.note) {
            var req = Restangular.one("fabric_notes", id);
            req.note = fabric.note;
            promise = req.put();
          } else {
            promise = Restangular.one("fabric_notes", id).remove();
          }

          promise.then(function () {
            dirty = false;
            transit = false;
          });
        }

        // throttled note updater for changes to the text area
        var throttledUpdate = _.throttle(update, autosave_timeout, {leading: false});

        // As the note changes, set the note as dirty then queue up the 
        // throttled update.  It will execute after N seconds or whenever
        // the modal is closed.
        scope.$watch('fabric.note', function (note, notewas) {
          if (note !== notewas && !element.attr("disabled")) {
            dirty = true;
            throttledUpdate();
          }
        });

        // Run update once on destroy.  This will do nothing silently if
        // the value is unchanged or already in transit.
        scope.$on("$destroy", update);

        if (undefined == fabric.note) {
          element.attr("disabled", "disabled");
          Restangular.one("fabric_notes", id).get().then(
            // On success, set the note.  Note there's no need to actually
            // update the cache for this, as it's just an in-memory object cache.  
            // This could change if the cache is set to use localStorage or 
            // something else.
            function (data) { fabric.note = data.note; },

            // Even on failure, set the note as a string.  This will be
            // cached on the record and prevent repeat lookups for non-existant
            // notes (which check for `undefined`).
            function (data) { fabric.note = ""; }
          ).finally(function () {
            $timeout(function () { element.removeAttr("disabled"); });
          });
        }
      }
    };
  });

})(window);
