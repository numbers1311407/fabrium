;(function () {
  // app.service('currentUser', function (Restangular) {

  //   return {
  //     get: function () {
  //       Restangular.oneUrl("users", "/profile.json").get().then(function (user) {

  //         if (!user.isAdmin()) {

  //           // This defies expectation a bit, but the way Restangular works,
  //           // it does not update existing "models" as you might think.  There
  //           // may be a way to do this but it was not obvious.  As such the
  //           // scope's `cart` is created initially (in the case that the user
  //           // does not have a pending cart available)...
  //           $scope.cart = Restangular.one("cart");

  //           // ... and then replaces itself via a `get` if the request does 
  //           // not 404.
  //           $scope.cart.get().then(function (cart) {
  //             $scope.cart.variant_ids = cart.variant_ids;
  //           });

  //           $scope.$watch("cart.size()", function (v) {
  //             $("a.cart-link .count").text(v);
  //           });
  //         }

  //       });
  //     }
  //   }
  // });

  app.service('fabrics', function ($q, DSCacheFactory, Restangular) {
    DSCacheFactory('fabricCache', {
        // Items added to this cache expire after 15 minutes.
        maxAge: 90000,
        // This cache will clear itself every hour.
        // cacheFlushInterval: 600000,
        // Items will be deleted from this cache right when they expire.
        deleteOnExpire: 'aggressive'
    });

    var API = {
      get: function (id) {
        var promise, cached;
     
        if (cached = API.getCached(id)) {
          var deferred = $q.defer();
          deferred.resolve(cached);
          promise = deferred.promise;
        } else {
          promise = Restangular.one("fabrics", id).get();
          promise.then(function (data) {
            API.put(id, data);
          });
        }

        return promise;
      },

      getCached: function (id) {
        return DSCacheFactory.get('fabricCache').get(id);
      },

      put: function (id, data) {
        return DSCacheFactory.get('fabricCache').put(id, data);
      },

      update: function (id, data) {
        var cached = API.getCached(id);
        if (!cached) return false;
        angular.extend(cached, data);
        return API.put(id, cached);
      }
    };

    return API;
  });

  app.run(function (Restangular) {
    Restangular.extendModel("cart", function Cart (model) {

      if (!model.variant_ids) { 
        model.variant_ids = []; 
      }

      model.toggleItem = function (id) {
        this.hasItem(id) ? this.removeItem(id) : this.addItem(id);
      };

      model.addItem = function (id) {
        if (this.hasItem(id)) { return; }
        this.variant_ids.push(id);
        this.all("items").post({fabric_variant_id: id});
      };

      model.size = function () {
        return this.variant_ids.length;
      };

      model.removeItem = function (id) {
        if (!this.hasItem(id)) { return; }
        this.variant_ids.splice(this.variant_ids.indexOf(id), 1);
        this.one("items", id).remove();
      };

      model.hasItem = function (id) {
        return -1 !== this.variant_ids.indexOf(id);
      };

      return model;
    });

    Restangular.extendModel("users", function User (model) {
      // favorites come down as a list of ids, but lets track them as
      // a hash so they can be easily added/removed and watched by angular
      model.favorites = {};
      angular.forEach(model.favorite_fabric_ids, function (id) {
        model.favorites[id] = true;
      });

      model.isAdmin = function () {
        return this.meta_type == "Admin";
      };

      model.isMill = function () {
        return this.meta_type == "Mill";
      };

      model.isBuyer = function () {
        return this.meta_type == "Buyer";
      };

      model.hasFavorite = function (id) {
        return !!this.favorites[id];
      };

      model.addFavorite = function (id, sync) {
        this.favorites[id] = true;
        Restangular.all("favorites").post({fabric_id: id});
      };

      model.removeFavorite = function (id) {
        delete this.favorites[id];
        Restangular.one("favorites", id).remove();
      };

      model.toggleFavorite = function (id) {
        this.hasFavorite(id) 
          ? this.removeFavorite(id, true) 
          : this.addFavorite(id, true);
      };

      return model;
    });
  });
})();
