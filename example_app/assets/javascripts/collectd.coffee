
class CollectdPage extends GraphPage
  constructor: (container, host) ->
    super(container, host)
    
    @addGraph("NetworkGraph", "en0", 1 * Size.megabyte )
    @addGraph("NetworkGraph", "en1", 1 * Size.megabyte )
    @addGraph("MemoryGraph")
    @addGraph("LoadGraph", 2.0)

$ ->
  graphs = []
  
  $('#toggle_config').click ->
    $("#config_panel").fadeToggle()
  
  container = $("#graphs")
  
  page = new CollectdPage(container, "pomme.local")
  page.refresh(30)
  
  $("#rangeselect").chosen().change ->
    page.refresh( $(this).val() )