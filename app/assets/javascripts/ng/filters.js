;(function () {

  /**
   * Format the `tags` array of a resource for display
   */
  app.filter("tags", function () {
    return function (input) {
      return input.length ? input.join(", ") : "None";
    }
  });


  /**
   * Format boolean values into something more vernacular
   */
  app.filter("yesno", function () {
    return function (input) {
      return input ? "Yes" : "No";
    }
  });


  /**
   * Format the `width` of a resource for display
   */
  app.filter("width", function () {
    return function (input) {
      return input && input + " CM";
    }
  });


  /**
   * Format the `fiber_content` of a resource for display
   */
  app.filter("materials", function () {
    var delim = "; ";

    return function (input) {
      if (!input) return "";

      var out = _.map(input, function (o) {
        if (!(o.percentage && o.fiber)) return;
        return "{0}% {1}".format(Number(o.percentage), o.fiber);
      });

      return _.compact(out).join(delim);
    }
  });


  /**
   * Return a default value for falsy expressions.
   */
  app.filter("default", function () {
    var defaultValue = "Not Entered";

    return function (input, value) {
      return input || value || defaultValue;
    }
  });


  /**
   * Format the `weight` object of a resource for display
   */
  app.filter("weight", function ($sce) {
    var map = {
      osy: "Oz/y<sup>2</sup>",
      glm: "GLM",
      gsm: "GSM"
    };

    return function (input) {
      if (!input) return "";

      var out = _.map(input, function (v, k) {
        return v+" "+map[k];
      }).join("; ");

      return $sce.trustAsHtml(out);
    }
  });

  app.filter("price_per_yard", function () {
    var rate = 0.9144;

    return function (price) {
      var ret = _.reduce(price, function (o, val, key) {
        o[key] = {
          min: parseFloat(val.min) * rate,
          max: parseFloat(val.max) * rate
        };
        return o;
      }, {});

      return ret;
    }
  });


  /**
   * Format the `price` object of a resource for display
   */
  app.filter("price_to_s", function () {
    var to = " to ";
    var delim = "; ";
    var currency_map = {
      us: {symbol: '$'},
      eu: {symbol: '€'}
    };

    return function (price, currency) {
      currency || (currency = 'us');
      // dig into price for the currency
      price = price && price[currency];

      if (!price) return "";

      var data = currency_map[currency]
        , cur = data.symbol
        , min = parseFloat(price.min)
        , max = parseFloat(price.max)

      // currencyify the output decimals
      min = min.toFixed(2);
      max = max.toFixed(2);

      return '0.00' === max
        ? ""
        : min === max
        ? "{0}{1}".format(cur, min)
        : "{0}{1} {2} {0}{3}".format(cur, min, to, max)
    }
  });

  /**
   * Retrieve an href from a `links` property of a returned resource
   * by the `rel` of the link.  e.g.:
   *
   *     resource.links | link:'self'
   */
  app.filter("link", function () {
    return function (input, rel) {
      var found = _.find(input || [], function (link) {
        return rel === link.rel;
      });
      return found && found.href || "";
    }

    return model;
  });
})();
