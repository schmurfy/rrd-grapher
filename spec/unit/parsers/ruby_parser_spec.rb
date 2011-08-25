require File.expand_path('../../../common', __FILE__)
require File.expand_path('../../../../lib/rrd-grapher/notifier/parsers/ruby_parser', __FILE__)

# as helper to build packets
require File.expand_path('../../../helpers/collectdrb', __FILE__)

describe 'Collectd Ruby parser' do
  before do
    @parser = RRDNotifier::RubyParser
  end
  
  describe 'Simple packets' do
    it 'can parse numbers' do
      type, val, buffer = @parser.parse_part( Collectd::number(1, 122) )
      buffer.should == ""
      val.should == 122
      
      type, val, _ = @parser.parse_part( Collectd::number(1, 2500) )
      val.should == 2500
      
      type, val, _ = @parser.parse_part( Collectd::number(1, 356798) )
      val.should == 356798
    end
    
    should 'parse strings' do
      type, str, _ = @parser.parse_part( Collectd::string(0, "hostname1") )
      str.should == 'hostname1'
      
      type, str, _ = @parser.parse_part( Collectd::string(0, "string with spaces") )
      str.should == 'string with spaces'
      
      type, str, _ = @parser.parse_part( Collectd::string(0, "a really long string with many words in it") )
      str.should == 'a really long string with many words in it'
    end
    
    should 'parse values' do
      buffer = Collectd.values([[:counter, 1034], [:derive, -4567], [:derive, 34]])
      type, values, rest = @parser.parse_part( buffer )
      rest.should == ""
      values.should == [1034, -4567, 34]
    end
  end
  
  describe 'One notification in buffer' do
    before do
      @now = Time.new.to_i
      
      @pkt = ""
      @pkt << Collectd.number(1, @now)
      @pkt << Collectd.string(0, 'hostname')
         
      @pkt << Collectd.string(2, 'plugin')
      @pkt << Collectd.string(3, 'plugin_inst')
      @pkt << Collectd.string(4, 'type')
      @pkt << Collectd.string(5, 'type_inst')
      @pkt << Collectd.number(257, 2) # severity
      @pkt << Collectd.string(256, 'a message')
    end
    
    should 'parse the notification' do
      data, rest = @parser.parse_packet(@pkt)
      
      rest.should == ""
      
      data.class.should             == RRDNotifier::Packet
      data.host.should              == 'hostname'
      data.time.should              == @now
      data.plugin.should            == 'plugin'
      data.plugin_instance.should   == 'plugin_inst'
      data.type.should              == 'type'
      data.type_instance.should     == 'type_inst'
      data.message.should           == 'a message'
      data.severity.should          == 2
      
    end
  end
  
  describe 'One packet in buffer' do
    before do
      @now = Time.new.to_i
      @interval = 10
      @pkt = ""
      @pkt << Collectd.number(1, @now)
      @pkt << Collectd.string(0, 'hostname')
      @pkt << Collectd.number(7, @interval)
         
      @pkt << Collectd.string(2, 'plugin')
      @pkt << Collectd.string(3, 'plugin_inst')
      @pkt << Collectd.string(4, 'type')
      @pkt << Collectd.string(5, 'type_inst')
      
      @pkt << Collectd.values([[:counter, 1034], [:gauge, 3.45]])
    end
    
    should 'parse it' do
      data, rest = @parser.parse_packet(@pkt)
      
      data.class.should            == RRDNotifier::Packet
      data.host.should             == 'hostname'
      data.time.should             == @now
      data.interval.should         == @interval
      data.plugin.should           == 'plugin'
      data.plugin_instance.should  == 'plugin_inst'
      data.type.should             == 'type'
      data.type_instance.should    == 'type_inst'
      
      data.values.size.should      == 2
      data.values[0].should        == 1034
      data.values[1].should        == 3.45
      
      rest.should == ""
    end
  end
  
  describe "Multiple packets in buffer" do
     before do
       @now = Time.new.to_i
       @interval = 10
   
       @pkt = Collectd.string(0, 'hostname')
       @pkt << Collectd.number(1, @now)
       @pkt << Collectd.number(7, @interval)
          
       @pkt << Collectd.string(2, 'plugin')
       @pkt << Collectd.string(3, 'plugin_inst')
       @pkt << Collectd.string(4, 'type')
       @pkt << Collectd.string(5, 'type_inst')
       
       @pkt << Collectd.values([[:counter, 1034], [:gauge, 3.45]])
       
       @pkt << Collectd.string(2, 'plugin2')
       @pkt << Collectd.string(3, 'plugin2_inst')
       @pkt << Collectd.string(4, 'type2')
       @pkt << Collectd.string(5, 'type2_inst')
       
       @pkt << Collectd.values([[:counter, 42]])
  
       
       @pkt << Collectd.string(5, 'type21_inst')
       @pkt << Collectd.values([[:gauge, 3.1415927]])
     end
     
     should 'parse it' do
       data = @parser.parse(@pkt)
       
       data.size.should == 3
       
       data[0].class.should == RRDNotifier::Packet
       
       data[0].host.should              == 'hostname'
       data[0].time.should              == @now
       data[0].interval.should          == @interval
       data[0].plugin.should            == 'plugin'
       data[0].plugin_instance.should   == 'plugin_inst'
       data[0].type.should              == 'type'
       data[0].type_instance.should     == 'type_inst'
       data[0].values.size.should       == 2
       data[0].values[0].should         == 1034
       data[0].values[1].should         == 3.45
       
       data[1].host.should              == 'hostname'
       data[1].time.should              == @now
       data[1].interval.should          == @interval
       data[1].plugin.should            == 'plugin2'
       data[1].plugin_instance.should   == 'plugin2_inst'
       data[1].type.should              == 'type2'
       data[1].type_instance.should     == 'type2_inst'
       data[1].values.size.should       == 1
       data[1].values[0].should         == 42
       
       data[2].host.should              == 'hostname'
       data[2].time.should              == @now
       data[2].interval.should          == @interval
       data[2].plugin.should            == 'plugin2'
       data[2].plugin_instance.should   == 'plugin2_inst'
       data[2].type.should              == 'type2'
       data[2].type_instance.should     == 'type21_inst'
       data[2].values.size.should       == 1
       data[2].values[0].should         == 3.1415927
       
     end
   end
  
end
