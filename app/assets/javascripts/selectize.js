;(function () {
  Selectize.define('close_button', function(options) {
    var api = this;

    options = $.extend({}, {
      right: '10px',
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
              cursor: "pointer",
              display: "none"
            })
            .on("click", function () {
              api.close(); 
            })
            .appendTo(api.$control);

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
