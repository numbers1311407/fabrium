$(function () {
  $(".form-group.fabric_weight").each(function () {
    var $input = $("input", this),
      $select = $("select", this),
      data = $input.data();

    $select.on("change", function () {
      $input.val(data[$select.val()]);
    });
  });

  $(".form-group.fibers").each(function () {
    var $el = $(this), 
        $tv = $el.find(".totals-value input"),
        $ass = $el.find(".property-assignments");

    var activeSelector = ".property-assignment:not(.inactive) [type=number]";

    var updateTotal = function () {
      var vals = $.makeArray($ass.find(activeSelector).map(function () {
        return Number($(this).val());
      }));

      var total = _.reduce(vals, function(m, v) { 
        return m + v; 
      }, 0);

      total = Math.max(total, 0);

      $tv.toggleClass("invalid", total !== 100);
      $ass.toggleClass("hidden", vals.length == 0);

      $tv.val(total);
    };

    updateTotal();
    $el.on("change", updateTotal);
  });

  $(".form-group.price_range").each(function () {
    var $el = $(this);
    var $sel = $el.find("select");

    var updateForm = function () {
      $el.find(".price_range_upper").toggleClass("hidden", $sel.val() == 0);
    }

    updateForm();

    $sel.on("change", updateForm);
  });
});
