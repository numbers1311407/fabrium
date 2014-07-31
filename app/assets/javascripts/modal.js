;(function () {

  // add a "ready' for modal show, so that code can be re-run when a modal
  // is opened
  utils.addReady(function (fn) {
    $(document).on("show.bs.modal", fn);
  });

  function renderFormErrors ($form, errors) {
    // remove the error blocks
    $form.find(".has-error.help-block").remove();

    // and clean up any remaining error classes
    $form.find(".has-error").removeClass(".has-error");

    // then add back the messages
    Object.keys(errors).forEach(function (key) {
      var $input = $form.find('[name$="['+key+']"]');

      $('<span class="has-error help-block" />')
        .html(errors[key][0]).insertAfter($input);

      $input.closest(".form-group").addClass("has-error");
    });
  }

  $(document).on("click", "a[rel~=modal]", function (e) {
    e.preventDefault();

    // the modal is a footer element that exists in the application layout
    var $modal = $("#common-modal");

    var handler = function (res) {
      var $wrap = $("<div></div>").html(res);
      var title = $wrap.find("#content-title").text();

      $modal.find(".modal-title").text(title);

      var $body;

      // if the body is a form (likely) ...
      if (($body = $wrap.find("form")).length) {
        $body
          // style the footer buttons in the modal
          .find(".form-actions").addClass("modal-footer").end()
          // make the form remote
          .attr("data-remote", true)
          // set it's type to json
          .attr("data-type", "json")
          // and attach handlers for success/error
          .on("ajax:error", function (e, xhr) {
            if (422 === xhr.status) {
              var errors = JSON.parse(xhr.responseText).errors;
              renderFormErrors($body, errors);
            }
          })
          .on("ajax:success", function (e, res, status, xhr) {
            utils.parseXhrFlash(xhr);
            $modal.modal("hide");
          });
      } 
      // otherwise just transfer over the content body
      else {
        $body = $wrap.find("#content-body");
      }

      $body.addClass("modal-body");
      $modal.find(".modal-container").html($body);

      $modal.modal();
    }

    var xhr = $.get(this.href);
    // make xhr available somehow? Maybe a data-attr of the modal?
    xhr.done(handler);
  });
})();
