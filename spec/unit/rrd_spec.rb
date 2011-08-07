require File.expand_path('../../common', __FILE__)

require File.join(ROOT, 'lib/rrd-grapher/rrd')

describe 'RRD Reader' do
  
  describe 'test.rrd' do
    before do
      path = File.expand_path('../../data/test.rrd', __FILE__)
      @rrd = RRDReader::File.new(path)
    end
    
    [
      {"cf"=>"AVERAGE", "rows"=>24, "cur_row"=>1, "pdp_per_row"=>1, "xff"=>0.5, "cdp_prep"=>0},
      {"cf"=>"AVERAGE", "rows"=>10, "cur_row"=>7, "pdp_per_row"=>6, "xff"=>0.5, "cdp_prep"=>0}
    ]
    
    should 'return correct RRA' do
      @rrd.rra.should.not == []
      
      # first
      with(@rrd.archives[0]) do |a|
        a.cf.should == :average
        a.rows.should == 24
        a.current_row.should == 1
        a.instance_variable_get('@pdp_per_row').should == 1
        a.instance_variable_get('@xff').should == 0.5
        a.instance_variable_get('@cdp_prep').should == 0
        
        a.interval.should == 5*60      # 5 minutes
        a.duration.should == 2*60*60   # 2 hours
      end
      
      # second
      with(@rrd.archives[1]) do |a|
        a.cf.should == :average
        a.rows.should == 10
        a.current_row.should == 7
        a.instance_variable_get('@pdp_per_row').should == 6
        a.instance_variable_get('@xff').should == 0.5
        a.instance_variable_get('@cdp_prep').should == 0
        
        a.interval.should == 30*60      # 30 minutes
        a.duration.should == 5*60*60    # 5 hours
      end
    end
    
  end
  
end
