var app = require("./app");

app.factory('Fabric', ['$resource', 
  function($resource){
    return $resource('fabrics/:id.json', {}, {
      query: {method:'GET', url: 'fabrics.json', isArray: true}
    });
  }]);
