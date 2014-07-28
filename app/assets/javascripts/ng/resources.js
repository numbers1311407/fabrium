;(function (root) {

  app.factory('FabricVariant', ['$resource', 
    function ($resource) {
      return $resource('fabric_variants/:id.json', {}, {
        query: {method:'GET', url: 'fabric_variants.json', isArray: true}
      });
    }]);

  app.factory('Tag', ['$resource', 
    function ($resource) {
      return $resource('tags/:id.json', {}, {
        query: {method:'GET', url: 'tags.json', isArray: true}
      });
    }]);

})(window);
