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


    $(".popover-hint").each(function () {
      var $el = $(this);
      var help = $('<span style="cursor: pointer; margin-left: 3px;"> <i class="fa fa-question-circle" ></i></span>');
      help.appendTo($el.find("label"));

      help.popover({
        trigger: "hover",
        html: true,
        template: '<div class="popover popover-wide" role="tooltip"><div class="arrow"></div><h3 class="popover-title"></h3><div class="popover-content popover-content-wide"></div></div>',
        // by putting the popover in the same container we can keep the
        // popover open when hovering it (and mousing off the trigger)
        placement: "right",
        content: $el.find(".help-block").html()
      });
    });
  }

  $(init);
}());
