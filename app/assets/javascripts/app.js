;(function ($) {
  window.utils = {};

  var callbacks = [];

  utils.ready = function (fn) {
    callbacks.push(fn);
  };

  utils.addReady = function (fn) {
    fn(utils.runReadyCallbacks);
  }

  utils.runReadyCallbacks = function () {
    $.each(callbacks, function (i, callback) {
      callback.call();
    });
  }

  utils.addReady($);

  /**
   * Util to parse rails flash messages out of xhr headers and display
   * them as alerts.
   */
  utils.parseXhrFlash = function (xhr) {
    var msg = xhr.getResponseHeader('x-message')
      , msgType = xhr.getResponseHeader('x-message-type');

    if (!msg) { return; }

    if ('error' == msgType) {
      alertify.error(msg, '', 0);
    } else {
      alertify.log(msg);
    }
  };

  utils.printElement = function (elem, append, delimiter) {
    var domClone = elem.cloneNode(true);

    var $printSection = document.getElementById("printSection");

    if (!$printSection) {
      var $printSection = document.createElement("div");
      $printSection.id = "printSection";
      document.body.appendChild($printSection);
    }

    if (append !== true) {
      $printSection.innerHTML = "";
    }

    else if (append === true) {
      if (typeof (delimiter) === "string") {
        $printSection.innerHTML += delimiter;
      }
      else if (typeof (delimiter) === "object") {
        $printSection.appendChlid(delimiter);
      }
    }
    $printSection.appendChild(domClone);
  }

})(jQuery);
