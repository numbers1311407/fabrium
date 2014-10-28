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
  app.directive('advancedOptions', function($compile, $timeout) {
    return {
      restrict : 'C', 
      compile : function (tElement, tAttrs, transclude) {

        var tmpl = '<div ng-show="ao_show" ng-click="ao_show = false" id="screen"></div><div class="advanced-options-panel" ng-show="ao_show"><ul>';

        var map = {}, revmap = {};

        tElement.find(".advanced-option").each(function () {
          var $el = $(this)
            , id = $el.attr("id")
            , name = id.replace(/ao_/, "")
            , option = "ao." + name
            , label = $el.find("> legend").text()

          map[name] = $el.find("[ng-model^='search.']").map(function () {
            return $(this).attr("ng-model").replace("search.", "");
          }).get();

          _.each(map[name], function (option) { 
            revmap[option] = name; 
          });

          tmpl += '<li class="checkbox"><label><input type="checkbox" ng-model="'+option+'" />'+label+'</label></li>';
          $el.attr("ng-show", option);
        });

        tmpl += "</ul>";

        tmpl += '<br/><button class="btn btn-primary" ng-click="ao_show=false">Close</button>';

        tmpl += "</div>";

        tElement.find(".advanced-options-configure").after(tmpl);

        return function (scope, element, attrs, transclude) { 

          var ao = scope.ao = {};

          _.each(scope.search, function (val, option) {
            if (revmap[option]) {
              ao[revmap[option]] = true;
            }
          });

          scope.$watch("ao.in_stock", function (value) {
            if (value) { scope.search.in_stock = '1'; }
          });

          scope.$watch("ao.favorites", function (value) {
            if (value) { scope.search.favorites = '1'; }
          });

          scope.$watch("ao_show", function (value) {
            if (!value) {
              var deleted = 0;

              angular.forEach(scope.ao, function (value, options) {

                if (!value) {
                  _.each(map[options], function (option) {
                    delete scope.search[option];
                  });

                  deleted++;
                }
              });

              if (deleted) {
                scope.updateSearch();
              }
            }
          });
        }
      }
    };
  });

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
        index: "=",
        update: "=",
        bubble: '=bubbleClickEvents'
      },

      link: function (scope, elem, attrs) {
        // timeout to come in after the ng-repeat
        $timeout(function () {
          $(elem).cycle({
            startingSlide: scope.index || 0,
            pagerEventBubble: !!scope.bubble
          });

          if (undefined !== scope.index) {
            scope.$watch("index", function (index) {
              $(elem).cycle("goto", index);
            });
          }

          if (undefined !== scope.update) {
            $(elem).on("cycle-before", function (e, API) {
              scope.update(API.nextSlide);
            });
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
        fabric: '=fabricNotesFor'
      },

      link: function(scope, element, attrs) {
        var fabric = scope.fabric;
        var id = fabric.id;
        var dirty = false;
        var inTransit = false;

        // note updating function
        var update = scope.updateNote = function () {

          // if the note isn't dirty, or if it's already inTransit, return
          if (!dirty || inTransit) {
            return;
          }

          // mark it as in inTransit
          inTransit = true;

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
          });

          promise.finally(function () {
            inTransit = false;
          });
        }

        // Create a throttled note updater for changes to the text area  Note
        // that the updater does not fire on the leading call, but only after
        // the configured timeout.
        var throttledUpdate = _.throttle(update, autosave_timeout, {
          leading: false
        });

        // As the note changes, set the note as dirty then queue up the 
        // throttled update.
        scope.$watch('fabric.note', function (note, notewas) {
          if (note !== notewas && !element.attr("disabled")) {
            dirty = true;
            throttledUpdate();
          }
        });

        // Run update once on destroy.  This will do nothing silently if
        // the value is unchanged or already in transit.
        scope.$on("$destroy", update);

        // Run on blur, again will do nothing if the value is unchanged.
        element.on("blur", update);

        // If the note is undefined (it will be on a new fabric as the note is
        // not a property of a fabric alone), then load the note from the server.
        // After the initial load, this will not happen again until the cache is
        // cleared.  Note changes will happen immediately with save firing async
        // but not affecting the note.
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
