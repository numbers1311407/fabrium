;(function (root) {

  app.factory('Fabric', ['$resource', 
    function ($resource) {
      return $resource('fabrics/:id.json', {}, {
        query: {method:'GET', url: 'fabrics.json', array: true}
      });
    }]);

  app.factory('FabricVariant', ['$resource', 
    function ($resource) {
      return $resource('fabric_variants/:id.json', {}, {
        query: {method:'GET', url: 'fabric_variants.json', isArray: true}
      });
    }]);

  app.factory('properties', ['$http', '$q',
    function ($http, $q) {

      var types = {
        keywords: '/props/keywords.json',
        categories: '/props/categories.json'
      };

      return {
        fetch: function (type, params) {
          var deferred = $q.defer(), url;

          if (url = types[type]) {
            $http.get(url, {params: params})
              .success(deferred.resolve)
              .error(deferred.reject);
          } else {
            deferred.reject('property type: ' + type + ' not found');
          }
          
          return deferred.promise;
        }
      }
    }]);


})(window);
