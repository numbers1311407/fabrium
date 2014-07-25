;(function () {

  var origCompact = _.compact;

  _.mixin({
    compact: function(o) {
      if (_.isArray(o)) {
        return origCompact.call(_, o);
      }
      _.each(o, function(v, k) {
        if (!v) { delete o[k]; }
      });
      return o;
    }
  });

})();
