
class DataStruct

  def initialize(*args)
    merge_data_from(*args)
  end
  
  ##
  # Merge new data in the structure.
  # 
  # @param [Object,Hash] opts_or_obj Source
  # @param [Array] only_fields an array of symbol
  #   specifying which fields to copy
  # @param [Boolean] allow_nil If false nil values from
  #   the source will not be copied in object
  # 
  def merge_data_from(opts_or_obj = {}, only_fields = nil, allow_nil = false)
    self.class.attributes.select{|attr_name| selected_field?(attr_name, only_fields) }.each do |attr_name|
      v = opts_or_obj.is_a?(Hash) ? (opts_or_obj[attr_name.to_s] || opts_or_obj[attr_name]) : opts_or_obj.send(attr_name)
      if allow_nil || !v.nil?
        send("#{attr_name}=", v)
      end
    end
  end
  
  def selected_field?(field, list)
    list.nil? || list.include?(field.to_sym)
  end


  class <<self  
    def properties(*names)
      names.each do |name|
        attr_accessor(name)
        (@attributes ||= []) << name
      end
    end
    
    alias :property :properties

    def attributes
      @attributes
    end
  end

end