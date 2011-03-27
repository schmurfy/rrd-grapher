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
      
      raise Sinatra::NotFound unless ::File.exists?(@path)
      parse_data(@path)
    end
  
    def to_json(*args)
      ret = {
        :short_name => @short_name,
        :step => @step,
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
      ret = RRD::Wrapper.fetch(@path, consolidation_function.to_s.upcase, *line_params)
      if ret.is_a?(Array)
        ret = ret[1..-1].inject({}) do |h, (t,v)|
          h[t] = v.finite? ? v : nil
          h
        end
      end
      
      ret
    end

  private
    def parse_data(path)
      data = RRD::Wrapper.info(path)
      
      @filename = data['filename']
      @rrd_version = data['rrd_version']
      @step = data['step']
      @last_update = Time.at(data['last_update'])
      
      @rra = []
      @ds = {}
      
      # and now ds and rra
      # TODO: parse these eventually
      # "rra[0].cdp_prep[0].value"=>NaN,
      # "rra[0].cdp_prep[0].unknown_datapoints"=>7,
      data.each do |key, val|
        case key
        when %r{^ds\[([a-zA-Z_]+)\]\.([a-zA-Z_]+)}
          @ds[$1] ||= {}
          @ds[$1][$2] = val

        when %r{^rra\[([0-9]+)\]\.([a-zA-Z_]+)}
          @rra[$1.to_i] ||= {}
          @rra[$1.to_i][$2] = val
        
        end
      end
    
      @rra.map!{|v| RRA.new(@step, v) }
    end
  end
end
