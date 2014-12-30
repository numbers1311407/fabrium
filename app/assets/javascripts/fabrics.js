$(function () {
  $("form#fabrics_form").each(function () {
    var $form = $(this);
    var el = $form.find("[name='fabric[mill_id]']")[0];

    if (!el || !el.selectize) { return; }

    var select = el.selectize;

    // extract the ID of the form if this is an update, which will be
    // passed in the query (so we don't fail on changing from and to the
    // item number already assigned to the form).
    var id, match;
    if (match = $form.attr("action").match(/fabrics\/(\d+)$/)) {
      id = match[1];
    }

    var getUrl = function (mill_id) {
      var params = {fabric: {}};

      if (mill_id) {
        params.fabric.mill_id = mill_id;
      }

      if (id) { 
        params.nid = id; 
      }

      return "/data/test_item_number.json?" + $.param(params);
    };


    var validateForm = function (mill_id) {
      $form.removeData('validator');

      $form.validate({ 
        rules: { "fabric[item_number]": { remote: getUrl(mill_id) } }
      });
    }

    validateForm();

    select.on("change", function (mill_id) {
      validateForm(mill_id);

      $("#form-inner").setLoading();

      var xhr = $.ajax({
        url: "/fabrics/new",
        data: {fabric: {mill_id: mill_id}}
      })
      .then(function (result) {
        var $result = $(result);
        $("#form-inner").html($result.find("#form-inner").html());
        utils.runReadyCallbacks();
      });
    });
  });
});

utils.ready(function () {

  // On submitting the form, set all the position values to be that of
  // their order in the list.  Sorting the elements simply moves them
  // around, while on form submit the positions are taken into account.
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

      $(".fabric-variants input[type=submit]").show();
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

      $(".fabric-variants input[type=submit]").show();

      utils.runReadyCallbacks();
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
    
    // on new forms this will be empty
    if (_.isEmpty(data)) { return; }

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
      var $asses = $ass.find(activeSelector);

      // ensure 0 remains
      $asses.val(function (i, v) {
        return v || 0;
      });

      var vals = $.makeArray($asses.map(function () {
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
