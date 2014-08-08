;(function () {

  function init() {
    var wrapper = this;

    var $cartFormBlock = $(".cart-form-block", this)
      , $cartEmptyBlock = $(".cart-empty-block", this);

    $(".cart-item", this).on("ajax:success", function (e) {
      var $item = $(e.currentTarget);
      var id = $item.data("id");

      // remove the cart item
      $item.remove();
      // and the hidden id field which would be left behind
      $(".cart-items > input[value='"+id+"']").remove();

      // Decrement the menu items cart count "Cart (N)" by 1.
      //
      // NOTE this is handled in angular for adding items and is only
      // in place for the non-angular cart page
      //
      $(".cart-link .count").text(function (i, v) {
        return v - 1;
      });

      // Count the items left and hide/show the cart and empty notice
      // if there are none left
      var count = $(".cart-item", wrapper).length;
      $cartEmptyBlock.toggleClass("hidden", !!count);
      $cartFormBlock.toggleClass("hidden", !count);
    });
  }


  $(function () {
    $(".cart-form-wrapper").each(init);
  });
})();
