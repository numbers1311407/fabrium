;(function () {
  app.run(function (Restangular) {

    Restangular.extendModel("carts", function Cart (model) {
      // var baseroute = Restangular.one("carts", model.id);
      window.asshole = model;

      model.toggleItem = function (id) {
        this.hasItem(id) ? this.removeItem(id) : this.addItem(id);
      };

      model.addItem = function (id) {
        if (this.hasItem(id)) { return; }
        this.variant_ids.push(id);
        this.all("items").post({fabric_variant_id: id});
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
      angular.forEach(model.favorite_fabric_variant_ids, function (id) {
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
        Restangular.all("favorites").post({fabric_variant_id: id});
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
