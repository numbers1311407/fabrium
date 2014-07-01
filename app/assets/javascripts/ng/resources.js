;(function (root) {

  app.factory('Fabric', ['$resource', 
    function($resource){
      return $resource('fabrics/:id.json', {}, {
        query: {method:'GET', url: 'fabrics.json', isArray: true}
      });
    }]);

  app.factory('FabricVariant', ['$resource', 
    function($resource){
      return $resource('fabric_variants/:id.json', {}, {
        query: {method:'GET', url: 'fabric_variants.json'}
      });
    }]);

})(window);
