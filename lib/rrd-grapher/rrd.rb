require 'rrd'

unless Float.const_defined?(:NAN)
  class Float
    NAN = (0/0.0)
  end
end

module RRDReader
  
  class InvalidRRARange < RuntimeError; end;
  
  class RRA
    
    attr_reader :cf, :rows, :current_row
    
    # {"cf"=>"AVERAGE", "rows"=>24, "cur_row"=>1, "pdp_per_row"=>1, "xff"=>0.5, "cdp_prep"=>0},
    def initialize(step, h)
      @step = step
      
      @cf = translate_function( h.delete('cf') )
      @rows = h.delete('rows').to_i
      @cur_row = h.delete('cur_row').to_i
      @pdp_per_row = h.delete('pdp_per_row').to_i
      @xff = h.delete('xff').to_f
      @cdp_prep = h.delete('cdp_prep').to_f
    end
    
    def current_row; @cur_row; end
    
    def translate_function(cf)
      case cf
      when "AVERAGE"  then  :average
      when "MIN"      then  :min
      when "MAX"      then  :max
      else
        raise "Unknown function: #{cf}"
      end
    end
    
    # one point is saved every X seconds
    def interval
      @pdp_per_row * @step
    end
    
    # <rows> points are stored which translate to a duration of X
    def duration
      @rows * interval()
    end
    
    def to_json(*args)
      ret = {
        :function => @cf,
        :row => @rows,
        :current_row => @cur_row,
        :interval => self.interval,
        :duration => self.duration
      }
      
      ret.to_json(*args)
    end
    
    def clip_time(from, to, last_update)
      # compute start/end time for this rra
      # last 
      # first_slot_time = last_update
      diff = to -from
      
      raise InvalidRRARange if diff > duration
      
      # from/to must be a multiple of <interval>
      to = (to / interval).to_i * interval
      from = to - diff
      
      [from, to]
    end
    
  end
  
  class File  
    attr_reader :short_name, :rrd_version, :step, :last_update
  
    attr_reader :ds, :rra
    alias :archives :rra
  
    def initialize(path, base_path = nil)
      if base_path
        @path = ::File.join(base_path, path)
        @short_name = path
      else
        @path = @short_name = path
      end
      
      unless ::File.exists?(@path)
        puts "RRD Not found: '#{@path}'"
        raise Sinatra::NotFound
      end
      parse_data(@path)
    end
  
    def to_json(*args)
      ret = {
        :path => @path,
        :short_name => ::File.basename(@short_name, '.rrd'),
        :step => @step,
        :sources => self.ds.keys,
        :last_update => @last_update.iso8601
      }
      
      
      ret.to_json(*args)
    end
    
    
    
    # options:
    # - rra : clip from/to to ensure returned values come from this rra
    #
    def get_values(consolidation_function, from, to, opts = {})
      
      options = {}
      
      rra_id = opts[:rra]
      if rra_id
        options[:resolution] = @rra[rra_id].interval
        from, to = @rra[rra_id].clip_time(from, to, @last_update)
      end
      
      options[:start] = from.to_i
      options[:end] = to.to_i
      
      line_params = RRD.to_line_parameters(options)
      # RRD::Wrapper.xport("--start", "1266933600", "--end", "1266944400", "DEF:xx=#{RRD_FILE}:cpu0:AVERAGE", "XPORT:xx:Legend 0")
      ds_name = @ds.keys[0]
      ret = RRD::Wrapper.xport(*line_params, "DEF:v1=#{@path}:#{ds_name}:#{consolidation_function}", "XPORT:v1:v1")
      
      if ret.is_a?(Array)
        ret = ret[1..-1].inject({}) do |h, (t,v)|
          h[t] = v.finite? ? v : nil
          h
        end
      end
      
      ret
    end
    
    def xport_values(consolidation_function, from, to, opts = {})
      args = []
      args += ["--start", from.to_i.to_s]
      args += ["--end", to.to_i.to_s]
      
      if opts[:maxrows]
        rows = opts[:maxrows].to_i
        raise ArgumentError, "maxrows needs to be greater or equal to 10" unless rows >= 10
        args += ["--maxrows", rows.to_s]
      end
      
      if opts[:rra]
        rra_id = opts[:rra].to_i
        interval = @rra[rra_id].interval
        args += ['--step', interval.to_s]
      end
      
      if opts[:ds_name]
        ds_name = opts[:ds_name]
      else
        ds_name = @ds.keys[0]
      end
      
      args += ["DEF:v1=#{@path}:#{ds_name}:#{consolidation_function}", "XPORT:v1:v1"]
      
      ret = RRD::Wrapper.xport(*args)
      if ret.is_a?(Array)
        ret = ret[1..-1].inject({}) do |h, (t,v)|
          h[t.to_i] = v.finite? ? v : nil
          h
        end
      end
      
      ret
    end
    
    
    # rrdtool graph /dev/null \
    # DEF:min=exact.rrd:value:MIN \
    # DEF:max=exact.rrd:value:MAX \
    # PRINT:min:MAX:%.2lf \
    # PRINT:max:MAX:%.2lf
    
    def get_minmax(from = nil, to = nil)
      args = []
      args += ["--start", from.to_i.to_s] if from
      args += ["--end", to.to_i.to_s] if to
      
    end

  private
    def parse_data(path)
      data = RRD::Wrapper.info(path)
            
      @rra = []
      @ds = {}
      
      # and now ds and rra
      # TODO: parse these eventually
      # "rra[0].cdp_prep[0].value"=>NaN,
      # "rra[0].cdp_prep[0].unknown_datapoints"=>7,
      data.each do |key, val|
        case key
        when 'step'         then @step = val
        when 'rrd_version'  then @rrd_version = val
        when 'filename'     then @filename = val
        when 'last_update'  then @last_update = Time.at(val)
          
          # ds[value2].unknown_sec
        when %r{^ds\[([a-zA-Z0-9_]+)\]\.([a-zA-Z_]+)}
          @ds[$1] ||= {}
          @ds[$1][$2] = val

        when %r{^rra\[([0-9]+)\]\.([a-zA-Z_]+)}
          @rra[$1.to_i] ||= {}
          @rra[$1.to_i][$2] = val
        
        when 'header_size' # ignore it
        
        else
          puts "Unknown key: #{key}"
        end
      end
    
      @rra.map!{|v| RRA.new(@step, v) }
    end
  end
end
