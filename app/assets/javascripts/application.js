//= require ./shims
//= require ./app
//= require ./selectize
//= require ./underscore
//= require ./minicolors
//= require ./modal
//= require ./popovers
//
//= require ./fabrics
//= require ./mills
//= require ./fabric_variants
//= require ./carts
//= require ./validate

$(function () {
  $(".error-tooltip").each(function () {
    var $tt = $(this);

    $tt.next().tooltip({
      html: true,
      title: $tt.html()
    });

    $tt.remove();
  });

  $("input[data-query-updater]").each(function () {
    var $input = $(this)
      , name = $input.attr("name")
      , search = $.deparam(location.search.substr(1));

    var $closeBtn = 
      $('<span class="selectize-inline-close">&times;</span>')
        .css({
          position: "absolute",
          right: '10px',
          bottom: '6px',
          cursor: "pointer",
          display: "none",
          zIndex: 1000
        })
        .on("click", function () {
          $input.val('').trigger("input");
          $closeBtn.toggle(false);
        })
        .insertAfter($input);

    $input.css({ paddingRight: '30px' });
    $input.parent().css({ position: 'relative' });

    $input.val(search[name]);
    $closeBtn.toggle(!!search[name]);

    $input[0].autocomplete = 'off';

    // throttle the search to some degree
    var throttledChange = _.throttle(function ($el) {
      routing.onChange($el, name, $el.val());
    }, 600);

    $input.on("input", function () {
      var $el = $(this);
      $closeBtn.toggle(!!$el.val());
      throttledChange($el);
    });
  });


  $(".scope-select").on("routing:success", function (event, html) {
    // wrap the HTML in case it's not
    // html = "<div class='wrap'>"+html+"</div>";

    var $res = $(html).find("#collection-results");

    if ($res.length) {
      $("#collection-results").html($res.html());
    } else {
      throw "Error loading index";
    }
  });
});


// Ajax Routing
;(function () {

  var routing = window.routing = {};

  routing.get = function (url) {
    window.location.href = url;
  }

  routing.onChange = function ($el, name, value) {
    // "deparam" the current search into an object
    var search = $.deparam(location.search.substr(1));

    // if the current value is the `blankValue`, delete the key from
    // the query.
    if (!value) {
      delete search[name];
    }
    // otherwise set the key/value on the query
    else {
      search[name] = value;
    }

    // PAGE cannot be included in these scope change searches.  It would
    // be too confusing to be on page 2 then search for something with only
    // 1 page of results and find yourself looking at "no results"
    delete search.page;

    // // then rebuild the object as a search string.
    search = $.param(search);

    // get the current pathname and append the search to it, if the
    // search is not empty.
    var url = window.location.pathname;
    if (search) { url += "?" + search; }

    // ... then route to it!
    routing.get(url).then(function () {
      var args = Array.prototype.slice.apply(arguments);
      args.unshift("routing:success");
      $el.trigger.apply($el, args);
    });
  };

  // if pushState capable, set routing up up to use pushState, otherwise
  // it will just change the href.
  if (window.history.pushState) {
    routing.get = function (url) {
      history.pushState({routing: true}, "", url);
      return $.get(url);
    }

    $(window).on("popstate.routing", function (e) {
      var state = e.originalEvent.state;
      if (state !== null && state.routing)  {
        routing.get(location.href);
      }
    });
  }
})();


// Stolen mostly from angular's `parseKeyValue`
$.deparam = function (keyValue) {
  var tryDecodeURIComponent = function (value) {
    try {
      return decodeURIComponent(value);
    } catch(e) {
      // Ignore any invalid uri component
    }
  }

  var isDefined = function (value){
    return typeof value !== 'undefined';
  }

  var obj = {}, key_value, key;

  _.each((keyValue || "").split('&'), function (keyValue) {
    if ( keyValue ) {
      key_value = keyValue.replace(/\+/g,'%20').split('=');
      key = tryDecodeURIComponent(key_value[0]);
      if ( isDefined(key) ) {
        var val = isDefined(key_value[1]) ? tryDecodeURIComponent(key_value[1]) : true;
        if (!hasOwnProperty.call(obj, key)) {
          obj[key] = val;
        } else if(isArray(obj[key])) {
          obj[key].push(val);
        } else {
          obj[key] = [obj[key],val];
        }
      }
    }
  });
  return obj;
}
