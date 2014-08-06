;(function () {

  function init() {
    var wrapper = this;

    var $cartFormBlock = $(".cart-form-block", this)
      , $cartEmptyBlock = $(".cart-empty-block", this);

    $(".cart-item", this).on("ajax:success", function (e) {
      $(e.currentTarget).remove();
      var count = $(".cart-item", wrapper).length;

      // NOTE this is handled in angular for adding items and is only
      // in place for the non-angular cart page
      $(".cart-link .count").text(function (i, v) {
        return v - 1;
      });

      $cartEmptyBlock.toggleClass("hidden", !!count);
      $cartFormBlock.toggleClass("hidden", !count);
    });
  }


  $(function () {
    $(".cart-form-wrapper").each(init);
  });
})();
