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


$(function () {

  //
  // This code makes use of a trick in the form html which outputs a
  // freshly built nested resource as a template within a `<script>` tag 
  // which replaces instances of the nested resource index with `__INDEX__`,
  // making it easy to swap in an incrementing index counter and append
  // nested resource items to the form.
  //
  $("fieldset.nested-resources").each(function () {
    var $container = $(this);
    var $list = $container.find(".nested-resource-list");
    var rawTmpl = $container.find("script").html();

    // Start the index after the current length and count up.  This
    // number is really fairly arbitrary I think, it just has to result
    // in a unique name.
    var i = $list.length;

    $container.on("click", "a.add-nested-resource", function (e) {
      e.preventDefault();
      var $el = $("<div></div>").html(
        rawTmpl.replace(/__INDEX__/g, i++)
      );
      $list.append($el.html());
    });

    $container.on("click", "a.remove-nested-resource", function (e) {
      var $resource = $(this).closest(".nested-resource");
      var $destroyInput = $resource.find("[name$='[_destroy]']");

      if ($destroyInput.length) {
        $destroyInput.val(1);
        $resource.hide();
      } else {
        $resource.remove();
      }
    });
  });
});
