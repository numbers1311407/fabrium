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


  // TODO mills & fabrics use the same caching strategy.  This should be a prototype
  // or something.
  app.service('mills', function ($q, DSCacheFactory, Restangular) {
    var cacheName = 'millsCache';
    var resource = 'mills'

    DSCacheFactory(cacheName, {
        // Items added to this cache expire after 15 minutes.
        maxAge: 90000,
        // This cache will clear itself every hour.
        // cacheFlushInterval: 600000,
        // Items will be deleted from this cache right when they expire.
        deleteOnExpire: 'aggressive'
    });

    var API = {
      get: function (id, args) {
        args || (args = {});

        var promise, cached;
     
        if (cached = API.getCached(id)) {
          var deferred = $q.defer();
          deferred.resolve(cached);
          promise = deferred.promise;
        } else {
          promise = Restangular.one(resource, id).get(args);
          promise.then(function (data) {
            API.put(id, data);
          });
        }

        return promise;
      },

      getCached: function (id) {
        return DSCacheFactory.get(cacheName).get(id);
      },

      put: function (id, data) {
        return DSCacheFactory.get(cacheName).put(id, data);
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
      get: function (id, args) {
        args || (args = {});

        var promise, cached;
     
        if (cached = API.getCached(id)) {
          var deferred = $q.defer();
          deferred.resolve(cached);
          promise = deferred.promise;
        } else {
          promise = Restangular.one("fabrics", id).get(args);
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

  app.run(function ($q, Restangular) {

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

      model.getMillUrl = function () {
        Restangular.one("mill", model.mill_id);
      };

      model.isFree = function () {
        return _.all(model.price, function (v, k) {
          return parseFloat(v.max) == 0;
        });
      };

      return model;
    });

    Restangular.extendModel("users", function User (model) {

      model.getCart = (function () {
        var cart;

        return function () {
          if (model.isAdmin() || 'undefined' !== typeof cart) {
            var deferred = $q.defer();
            deferred.resolve(cart || null);
            promise = deferred.promise;
          } else {
            promise = Restangular.one("cart").get();
            promise.then(
              function (data) { cart = data; },
              function () { cart = false; }
            );
          }
          return promise;
        }
      })();

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
