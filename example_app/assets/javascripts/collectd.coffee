
class window.TestGraph extends GraphDefinition
  constructor: (container, host, @interface, ymin = null) ->
    super(host, container, "Test Traffic (#{interface})", [ Format.size, Format.size ], ymin)
    
    @graph.addSerie("#{@host}/interface/if_octets-#{@interface}", "rx", "(#{@interface}) Bytes Received")
    @graph.addSerie("#{@host}/interface/if_octets-#{@interface}", "tx", "(#{@interface}) Bytes Sent", 2)



class CollectdPage extends GraphPage
  constructor: (container, panel_container, host) ->
    super(container, panel_container, host)
    
    @addGraph("NetworkGraph", "en0", 1 * Size.megabyte )
    @addGraph("TestGraph", "en1", [20 * Size.kilobyte, 100 * Size.kilobyte ] )
    # @addGraph("MemoryGraph")
    @addGraph("LoadGraph", 2.0)

$ ->
  graphs = []
  
  container = $("#graphs")
  panel_container = $("#config_panel")
  
  page = new CollectdPage(container, panel_container, "pomme.home")
  # page.set_simple_interval(30)
  
  $("#dateselect").datepicker().change ->
    date_string = $(this).val()
    time = Date.parse(date_string) / 1000
    
    page.set_autorefresh(null)
    page.set_interval(time, time + 24*60*60)
  
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