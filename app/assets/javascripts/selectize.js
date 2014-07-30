$(function () {
  $("[data-select]").each(function () {
    var $el = $(this), options = $el.data('select');
    $el.selectize(options);
    window.api = $el[0].selectize;
  });
});

;(function () {
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
