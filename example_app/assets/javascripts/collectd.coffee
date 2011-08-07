
class CollectdPage extends GraphPage
  constructor: (container, panel_container, host) ->
    super(container, panel_container, host)
    
    @addGraph("NetworkGraph", "en0", 1 * Size.megabyte )
    @addGraph("NetworkGraph", "en1", 1 * Size.megabyte )
    @addGraph("MemoryGraph")
    @addGraph("LoadGraph", 2.0)

$ ->
  graphs = []
  
  container = $("#graphs")
  panel_container = $("#config_panel")
  
  page = new CollectdPage(container, panel_container, "pomme.local")
  page.set_simple_interval(30)
  
  $("#rangeselect").chosen().change ->
    page.set_autorefresh(null)
    page.set_simple_interval( $(this).val() )
  
  $("#linkedzoom").change (event) =>
    if $(event.currentTarget).attr("checked")
      page.refresh()
  
  $("#autorefresh").change (event) =>
    if $(event.currentTarget).attr("checked")
      page.set_autorefresh(5000)
    else
      page.set_autorefresh(null)