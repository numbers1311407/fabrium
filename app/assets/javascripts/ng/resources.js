;(function () {

  var Links = function (model) {
    model.link = function (rel) {

      var found = _.find(this.links || [], function (link) {
        return rel === link.rel;
      });

      return found && found.href;
    }

    return model;
  };

  app.run(function (Restangular) {


    Restangular.extendModel("fabric_variants", Links);


    Restangular.extendModel("users", function Favorites (model) {

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

      model.toggleFavorite = function (e, id) {
        e.stopPropagation();
        this.hasFavorite(id) 
          ? this.removeFavorite(id, true) 
          : this.addFavorite(id, true);
      };

      return model;
    });
  });
})();
