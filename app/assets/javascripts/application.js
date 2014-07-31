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

$(function () {
  $(".error-tooltip").each(function () {
    var $tt = $(this);

    $tt.next().tooltip({
      html: true,
      title: $tt.html()
    });

    $tt.remove();
  });
});
