$(function () {

  $("form#fabrics_form").submit(function (e) {
    $('tr.fabric-variant input[name$="[position]"]', this).each(function (i) {
      $(this).val(i);
    });
  });


  // statically size the fabric variants sortable table
  // elements so that when a sortable row is cloned, the
  // table and row don't resize when it is removed from
  // it's context.
  $("table.fabric-variants").each(function () {
    var $table = $(this);

    var resize = function () {
      $table.find("td, th").each(function () {
        $(this).width($(this).width());
      });
    }

    resize();

    $(window).on("resize.fabric_variants_table", resize);
  });

  $("[data-fabric-variants]").sortable({
    placeholder: 'placeholder-row',
    axis: 'y',
    handle: 'td.fabrium_id'
  });

  //
  // Set up the nested fabric variants form
  //
  $(".form-group.fabric_variants").each(function () {
    var selector = ".modal form.new_fabric_variant, .modal form.edit_fabric_variant";
    var $container = $("[data-fabric-variants]", this);
    var n = $container.children().length;
    var tmpl = _.template($("script", this).text());

    $container.on("click", ".remove", function () {
      var $el = $(this).closest(".fabric-variant"),
          id = $el.data("id"),
          $destroy = $("#destroy_fabric_variant_"+id);

      if ($destroy.length) {
        $destroy.val(1);
        $el.hide();
      } else {
        $el.remove();
      }
    });

    var render = function (data) {
      var $el = $container.find('[data-id='+data.id+']');

      if ($el.length) {
        $el.replaceWith(tmpl(data));
        $("#destroy_fabric_variant_"+data.id).val(0);
      } else {
        data.n = n++;
        $container.append(tmpl(data));
      }

      app.runReadyCallbacks();
    }

    $(document).on("ajax:success", selector, function (event, data, msg, xhr) {
      if (204 == xhr.status) {
        var loc = xhr.getResponseHeader('Location');
        $.getJSON(loc, render);
      } else {
        render(data);
      }
    });

  });

  //
  // On edit, the fabrics will have calculated values for GSM/GLM/OSY units,
  // with the value for each stored in data attributes.  On select change,
  // update the visible calculated weight value based on the units.
  //
  $(".form-group.fabric_weight").each(function () {
    var $input = $("input", this),
      $select = $("select", this),
      data = $input.data();

    $select.on("change", function () {
      $input.val(data[$select.val()]);
    });
  });


  //
  // Display and calculate the "total fiber percentage" field as materials
  // are added/removed/changed.
  //
  $(".form-group.materials").each(function () {
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


  //
  // Show the upper price range fields when the price range upper select
  // is set to 1 (not zero)
  //
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
