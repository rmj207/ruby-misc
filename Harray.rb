class Harray
  module Convert; end;
  def initialize initial
    error = "Harray#new requires a Hash#class or Array#class"
    raise ArgumentError, error unless Harray.accepted_types.include? initial.class
    @value = initial.extend(Convert)
  end

  class << self
    def accepted_types
      [Hash, Array]
    end
  end

  accepted_types.each do |klass|
    define_method "as_#{klass.to_s.downcase}" do
      @value = @value.kind_of?(klass) ? @value : @value.to_other
    end
  end

  def will_handle_method? method
    Harray.accepted_types.map{|c| c.instance_methods.include? method}.include? true
  end

  def method_missing method, *args, &block
    #super unless will_handle_method? method
    if method.to_s =~ /.*_as_array$/
      @value = @value.to_other unless @value.kind_of? Array
      @value.send(method.to_s.gsub(/_as_array/, ''), *args, &block)
    elsif method.to_s =~ /.*_as_hash$/
      @value = @value.to_other unless @value.kind_of? Hash
      @value.send(method.to_s.gsub(/_as_hash/, ''),*args, &block)
    else
      @value = @value.to_other unless @value.respond_to? method
      @value.send(method,*args, &block)
    end
  end

  module Convert
    def to_other
      new_self = self.kind_of?(Array) ? self.to_hash : self.to_array
      new_self.extend(Convert)
      new_self
    end

    def to_hash
      return self if self.kind_of? Hash
      self.inject({}) do |newHash, element|
        if element.kind_of? Array
          key = element.shift
          element = nil if element.empty?
          element = element.first if not element.nil? and element.length.eql? 1
          newHash[key] = element
        else
          newHash[element] = nil
        end
        newHash
      end
    end

    def to_array
      return self if self.kind_of? Array
      to_a.map{|elem|elem.length.eql?(2) and elem.last.nil? ? elem.first : elem}
    end
  end
end

