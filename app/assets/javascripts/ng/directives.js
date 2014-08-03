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
})(window);
