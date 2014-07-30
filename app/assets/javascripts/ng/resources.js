;(function (root) {

  app.factory('FabricVariant', function ($resource) {
    return $resource('fabric_variants/:id.json', {}, {
      query: {method:'GET', url: 'fabric_variants.json', isArray: true}
    });
  });

  app.factory('Tag', function ($resource) {
    return $resource('tags/:id.json', {}, {
      query: {method:'GET', url: 'tags.json', isArray: true}
    });
  });

  app.factory('Mill', function ($resource) {
    return $resource('mills/:id.json', {}, {
      query: {method:'GET', url: 'mills.json', isArray: true}
    });
  });

})(window);
