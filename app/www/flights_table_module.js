function flights_table_module_js(ns_prefix) {

    $("#" + ns_prefix + "flights_table").on("click", ".edit_btn", function() {
    Shiny.setInputValue(ns_prefix + "flight_id", this.id, { priority: "event"});
    $(this).tooltip('hide');
  });
  
}
