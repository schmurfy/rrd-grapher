require File.expand_path('../../common', __FILE__)
require File.expand_path('../../../lib/rrd-grapher/notifier', __FILE__)

# require 'eventmachine'

describe 'Notifier::Server' do
  should 'bind an udp socket on start' do
    EM::expects(:open_datagram_socket).with('local', 7777, RRDNotifier::Server, kind_of(RRDNotifier::AlarmManager), nil)
    RRDNotifier::Server.start(:host => 'local', :port => 7777)
  end
  
  should 'raise an error on unknown constructor option' do
    err = proc{
      RRDNotifier::Server.start(:i_am_invalid => "yes really !")
    }.should.raise()
    err.message.should.include?("Unknown arguments")
  end
  
  describe 'an existing notifier' do
    before do
      @alarm_manager = stub('alarm_manager')
      
      EM::stubs(:open_datagram_socket)
      @notifier = RRDNotifier::Server.new(nil, @alarm_manager)
    end
    
    should "delegate register_alarm to the alarm manager" do
      @alarm_manager.expects(:register_alarm).with(12, "a useless message")
      @notifier.register_alarm(12, "a useless message")
    end
    
    should 'dispatch parsed packets when data is received' do
      data = ""
      packets = [ Factory(:data_point), Factory(:data_point), Factory(:notification) ]
      
      @alarm_manager.expects(:packet_received).with(packets[0])
      @alarm_manager.expects(:packet_received).with(packets[1])
      @alarm_manager.expects(:packet_received).with(packets[2])
      
      RRDNotifier::BindataParser::expects(:parse).with(data).returns(packets)
      @notifier.receive_data(data)
    end
  end
  
end
