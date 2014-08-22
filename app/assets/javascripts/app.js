;(function ($) {
  window.utils = {};

  var callbacks = [];

  utils.getCrop = (function () {

    return function (src, w, h, cb) {
      var canvas = document.createElement('canvas');
      var context = canvas.getContext('2d');
      var imageObj = new Image();

      canvas.width = w;
      canvas.height = h;

      imageObj.onload = function() {
        context.drawImage(imageObj, 0, 0, w, h, 0, 0, canvas.width, canvas.height);
        cb(canvas.toDataURL());
      };

      imageObj.src = src;
    };
  })();

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


  var errorTmpl;

  utils.log = function (msg, type) {
    type || (type = "notice");
    var type = 'error' == type ? 'danger' : 'success';
    $("#alerts").empty().append(errorTmpl({msg: msg, type: type}));
  };

  utils.log.notice = function (msg) {
    utils.log(msg, 'notice');
  };

  utils.log.error = function (msg) {
    utils.log(msg, 'error');
  };

  /**
   * Util to parse rails flash messages out of xhr headers and display
   * them as alerts.
   */
  utils.parseXhrFlash = function (xhr) {
    var msg = xhr.getResponseHeader('x-message')
      , msgType = xhr.getResponseHeader('x-message-type');

    if (msg) { utils.log(msg, msgType); }
  };

  $(function () {
    errorTmpl = _.template( $("#alertTmpl").html() );

    $(document).on("ajax:complete", function (e, xhr) {
      utils.parseXhrFlash(xhr);
    });
  });

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
