;(function () {

  utils.ready(function () {
    $("[data-select]").each(function () {
      var $el = $(this), options = $el.data('select');
      $el.selectize(options);
    });
  });

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
            subapi.clearOptions();
            subapi.addOption(v);
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

        var name = this.$input.attr("name");

        var $blank = this.revertSettings.$children.filter("[value='']");
        var blankValue = "_blank";

        if (options.blank !== false && $blank.length) {
          // if this were more robust it'd make sure the valueField and
          // labelField were correct
          this.addOption({text: $blank.text(), value: blankValue});
          this.getValue() || this.setValue(blankValue);
        }

        // on change, we're going to try to update the query string with
        // the current key/value and route to that new url.
        this.on('change', function (value) {

          // if the blank option was not prevented and this is the `blankValue`
          // then set v to blank before passing it along
          if (options.blank !== false && value == blankValue) {
            value = '';
          }

          routing.onChange(self.$input, name, value);
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
        var $container = $parent.find(".property-assignments");
        var tmpl = _.template($parent.find("script").text());
        var n = $container.find(".property-assignment").length;

        $container.on("click", ".remove", function () {
          var $el = $(this).parent(),
              $destroy = $el.find('[name$="[_destroy]"]');

          if ($destroy.length) {
            $destroy.val(1);
            // this part is for materials, I think, the summation
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
