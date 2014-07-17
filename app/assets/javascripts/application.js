//= require ./selectize
//= require ./underscore
//= require ./fabrics


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
