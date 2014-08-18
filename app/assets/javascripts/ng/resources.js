;(function () {

  app.service('currentUser', function (Restangular, $q) {

    var object;

    return {
      get: function () {
        var promise;

        if (object) {
          var deferred = $q.defer();
          deferred.resolve(object);
          promise = deferred.promise;
        } else {
          promise = Restangular.oneUrl("users", "/accounts/profile.json").get();
          promise.then(function (data) { object = data; });
        }

        return promise;
      }
    }
  });


  app.service('currentCart', function (Restangular, $q) {
    var object;

    return {
      get: function (scope) {
        if ('undefined' !== typeof object) {
          var deferred = $q.defer();
          deferred.resolve(object);
          promise = deferred.promise;
        } else {
          promise = Restangular.one("cart").get();
          promise.then(
            function (data) { object = data; },
            function () { object = false; }
          );
        }
        return promise;
      }
    }
  });

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
        Restangular.one("cart").all("items").post({fabric_variant_id: id});
      };

      model.size = function () {
        return this.variant_ids.length;
      };

      model.removeItem = function (id) {
        if (!this.hasItem(id)) { return; }
        this.variant_ids.splice(this.variant_ids.indexOf(id), 1);
        Restangular.one("cart").one("items", id).remove();
      };

      model.hasItem = function (id) {
        return -1 !== this.variant_ids.indexOf(id);
      };

      return model;
    });


    Restangular.extendModel("fabrics", function Fabric (model) {
      model.getVariantUrl = function (position) {
        var search = position ? "?v="+position : "";
        return this.getRestangularUrl() + search;
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
