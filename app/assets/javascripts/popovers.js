;(function () {

  var init = function () {
    $(document).on('mouseover', 'a[rel~=popover]:not(.popover-initialized)', function (e) {
      var $popover = $(this);


      $popover.popover({
        trigger: 'hover',
        html: true,
        // by putting the popover in the same container we can keep the
        // popover open when hovering it (and mousing off the trigger)
        container: $popover,
        placement: function (po, el) {
          return $(el).data("placement") || "top";
        },

        content: function(po, el) {
          var $content = $(this).next(".hidden-content");
          if ($content.length) { 
            return $content.html(); 
          } 
          var $img = $(this).find("img");
          if ($img.length) {
            return '<img class="popover-thumb" src="'+$img.attr("src")+ '" />';
          }
        }
      })
      .addClass("popover-initialized")
      .trigger("mouseover");
    });
  }

  $(init);
}());
