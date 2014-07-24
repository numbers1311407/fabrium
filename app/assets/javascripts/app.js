;(function ($) {
  window.app = {};

  var callbacks = [];

  app.ready = function (fn) {
    callbacks.push(fn);
  };

  app.addReady = function (fn) {
    fn(app.runReadyCallbacks);
  }

  app.runReadyCallbacks = function () {
    $.each(callbacks, function (i, callback) {
      callback.call();
    });
  }

  app.addReady($);

  /**
   * Util to parse rails flash messages out of xhr headers and display
   * them as alerts.
   */
  app.parseXhrFlash = function (xhr) {
    var msg = xhr.getResponseHeader('x-message')
      , msgType = xhr.getResponseHeader('x-message-type');

    if (!msg) { return; }

    if ('error' == msgType) {
      alertify.error(msg, '', 0);
    } else {
      alertify.log(msg);
    }
  };

})(jQuery);
