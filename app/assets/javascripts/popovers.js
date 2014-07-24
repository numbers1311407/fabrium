;(function () {
  var init = function () {
    $('a[rel~=popover]').popover({
      html: true,
      trigger: 'hover',
      placement: 'left',
      content: function() {
        var $img = $(this).find("img");
        return '<img src="'+$img.attr("src")+ '" />';
      }
    }); 
  }

  app.ready(init);
}());
