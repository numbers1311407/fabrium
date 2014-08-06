$(function () {
  $("[data-select]").each(function () {
    var $el = $(this), options = $el.data('select');
    $el.selectize(options);
  });
});

;(function () {
  Selectize.define('country_select', function (options) {
    var api = this;

    api.setup = (function () {
      var original = api.setup;
      var subselect = $(options.subregion_select);
      var subapi = null;
      var endpoint = "/data/country_subregions.json";

      var subselect_options = {
        placeholder: 'Please select',
        mode: 'single'
      };

      // country_options should be a global var defined in the form
      var cache = country_options || {};

      var setOptions = function (v) {
        if (v.error || !v.length) {
          if (subapi) {
            subapi.clear();
            subapi.destroy();
            subapi = null;
          }
        } else {
          if (subapi) {
            subapi.setOptions(v);
          } else {
            subselect.selectize(_.extend({options: v}, subselect_options));
            subapi = subselect[0].selectize;
          }
        }
      };

      var load = function (country_code) {
        if (cache[country_code]) {
          return setOptions(cache[country_code]);
        };

        $.ajax({
          url: endpoint, 
          data: { country: country_code },
        }).done(function (res) {
          setOptions(cache[country_code] = res);
        });
      };

      return function () {
        original.apply(this, arguments);
        var v = this.$input.val();
        if (v) { load(v) };
        api.on("change", load);
      };
    })();
  });


  Selectize.define('route_on_change', function (options) {
    var self = this;

    self.setup = (function () {
      var original = self.setup;

      return function () {
        original.apply( this, arguments );

        var route = function (url) {
          window.location.href = url;
        }

        if (options.remote && window.history.pushState) {
          var ajaxGet = function (url) {
            $.get(url)
              .then(function () {
                var args = Array.prototype.slice.apply(arguments);
                args.unshift('ajax_success');
                self.trigger.apply(self, args);
              });
          }

          $(window).on("popstate", function (e) {
            var state = e.originalEvent.state;
            if (state !== null && state.scope)  {
              ajaxGet(location.href);
            }
          });

          route = function (url) {
            history.pushState({scope: true}, "", url);
            ajaxGet(url);
          }
        }

        var name = this.$input.attr("name");
        var $blank = this.revertSettings.$children.filter("[value='']");
        var blankValue = "_blank";

        if ($blank.length) {
          // if this were more robust it'd make sure the valueField and
          // labelField were correct
          this.addOption({text: $blank.text(), value: blankValue});
          this.getValue() || this.setValue(blankValue);
        }

        this.on('change', function (v) {
          if (!v) return;

          var param = v != blankValue ? name+'='+v : ''
            , s = location.search
            , rx = new RegExp(name+"=\\w+");

          // NOTE this original bit was to preserve the query, which
          // is fine but for the purposes here is not really necessary
          // as there's typically only going to be one param, besides
          // `page`, and `page` is probably something that should be
          // replaced on search query change (otherwise you end up with
          // empty results when the search is narrowed).
          //
          // Anyway, this could be better done using some kind of 
          // param/deparam plugin that parses and resets search.
          //
          // var search = (s) 
          //   ? s.match(rx)
          //     ? s.replace(rx, param)
          //     : param ? s + '&' + param : s
          //   : param ? '?'+param : '';
          // if ('?' == search) search = '';
          var search = param ? '?'+param : '';

          var url = window.location.pathname + search;

          route(url);
        });
      }
    })();
  });


  Selectize.define('clear_selection', function ( options ) {
    var self = this;

    self.plugins.settings.dropdown_header = {
      title: 'Clear Selection'
    };
    this.require( 'dropdown_header' );

    self.setup = (function () {
      var original = self.setup;

      return function () {
        original.apply( this, arguments );
        this.$dropdown.on( 'mousedown', '.selectize-dropdown-header', function ( e ) {
          self.setValue( '' );
          self.close();
          self.blur();

          return false;
        });
      }
    })();
  });

  Selectize.define('multiple_properties', function () {
    var api = this;

    this.setup = (function () {
      var setup = api.setup;

      return function () {
        setup.apply(this, arguments);

        var $parent = api.$input.parent();
        var $container = $parent.find("[data-property-assignments]");
        var tmpl = _.template($parent.find("script").text());
        var n = $container.find(".property-assignment").length;

        $container.on("click", ".remove", function () {
          var $el = $(this).parent(),
              $destroy = $el.find('[name$="[_destroy]"]');

          if ($destroy.length) {
            $destroy.val(1);
            $el.find('[type=number]').val(0);
            $el.addClass("inactive");
            $el.hide();
          } else {
            $el.remove();
          }

          $container.trigger("change");
        });

        api.on("item_add", function (value, $item) {
          var $existing = $container.find('[data-id='+value+']');

          if ($existing.length) {
            $existing.show();
            $existing.find('[name$="[_destroy]"]').val(0);
            $existing.removeClass("inactive");
          } else {
            $container.prepend(tmpl({ id: value, name: $item.html(), n: n++ }));
          }

          $container.trigger("change");
          api.clear();
        });
      }
    })();
  });

  Selectize.define('endpoint', function (options) {
    var api = this;

    options = $.extend({param: 'name'}, options);

    if (!options.url) {
      throw "selectize: endpoint requires a url param";
    }

    function load (query, callback) {
      if (!query.length) return callback();
      var search = {};
      search[options.param] = query;

      $.getJSON(options.url, search, function (data) {
        callback(_.map(data, function (o) {
          if ('string' == typeof o) {
            return { value: o, text: o };
          }
          return { value: o.id, text: o[options.param] };
        }));
      });
    }

    this.setup = (function () {
      var setup = api.setup;
      return function () {
        $.extend(this.settings, {
          load: load,
          sortField: 'text'
        });
        setup.apply(this, arguments);
      }
    })();
  });

  Selectize.define('open_placeholder', function (options) {
    var setup = this.setup, open_placeholder = options.placeholder;

    if (!open_placeholder) {
      throw 'selectize: open_placeholder plugin must be passed "placeholder" message';
    }

    this.setup = (function () {
      return function () {
        var api = this;

        setup.apply(api, arguments);

        var closed_placeholder = api.$control_input.attr("placeholder");

        api.on("dropdown_open", function (value, $item) {
          api.settings.placeholder = open_placeholder;
          api.updatePlaceholder();
        });

        api.on("dropdown_close", function (value, $item) {
          api.settings.placeholder = closed_placeholder;
          api.updatePlaceholder();
        });
      }
    })();
  });

  /**
   * Close button plugin
   */
  Selectize.define('close_button', function(options) {

    var api = this;

    options = $.extend({}, {
      right: '10px',
      top: '6px',
      paddingRight: '30px'
    }, options);

    this.setup = (function() {
      var setup = api.setup;

      return function () {
        setup.apply(this, arguments);

        api.$control.css({
          paddingRight: options.paddingRight,
          position: "relative"
        });

        var closeBtn = 
          $('<span class="selectize-inline-close">&times;</span>')
            .css({
              position: "absolute",
              right: options.right,
              top: options.top,
              cursor: "pointer",
              display: "none",
              zIndex: 1000
            })
            .on("click", function () {
              api.close(); 
            })
            .insertAfter(api.$control);

        api.on("dropdown_open", function () {
          closeBtn.css({display: ""});
        });

        api.on("dropdown_close", function () {
          closeBtn.css({display: "none"});
        });
      };
    })();
  });
})();
