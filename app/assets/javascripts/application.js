//= require ./shims
//= require ./app
//= require ./selectize
//= require ./underscore
//= require ./minicolors
//= require ./modal
//= require ./popovers
//
//= require ./fabrics
//= require ./fabric_variants
//= require ./carts

$(function () {
  $(".error-tooltip").each(function () {
    var $tt = $(this);

    $tt.next().tooltip({
      html: true,
      title: $tt.html()
    });

    $tt.remove();
  });

  $(".scope-select select").each(function () {
    var api = this.selectize;

    api.on("ajax_success", function (html) {
      var $res = $(html).find("#collection-results");
      if ($res.length) {
        $("#collection-results").html($res.html());
      } else {
        throw "Error loading index";
      }
    });
  });
});
