require 'bundler/setup'
require 'meta_tools'
require 'outline/version'

class Hash
  def to_outline
    convert_data = Proc.new do |data|
      data.each_with_object({}) do |(key, value), memo|
        if value.respond_to?(:to_hash) || value.respond_to?(:to_h)
          value = value.respond_to?(:to_hash) ? value.to_hash : value.to_h
          value = value.to_outline
        end
        
        memo[key] = value
      end
    end
    
    data = convert_data[ self ]
    
    Outline.new(data: data)
  end
end

class Outline
  # It's as if we are subclassing BasicObject, but without the loss of context (and object_id):
  (Object.instance_methods - BasicObject.instance_methods).each { |meth| remove_method(meth) unless [:object_id].include?(meth) rescue nil }
  include MetaTools
  include Enumerable
  
  attr_reader :parent, :data
  
  def initialize(opts={}, &blk)
    raise(TypeError, "opts must respond to :to_hash or be nil") unless opts.nil? || opts.respond_to?(:to_hash)
    raise(TypeError, "opts[:data] must respond to :to_h or :to_hash or be nil") unless opts[:data].nil? || opts[:data].respond_to?(:to_hash) || opts[:data].respond_to?(:to_h)
    
    opts = opts.to_hash
    data = opts[:data].respond_to?(:to_hash) ? opts[:data].to_hash : opts[:data].to_h unless opts[:data].nil?
    
    @parent = opts[:parent]
    @data = data
    @methods = []
    
    instance_eval(&blk) unless blk.nil?
  end
  
  def method_missing(meth, *args, &blk)
    meth = meth.to_s.gsub(/=$/, '').to_sym if meth =~ /=$/
    
    unless @methods.include?(meth)
      @methods << meth
      
      meta_def(meth) do |*values, &blk|
        block_given, values_given = !blk.nil?, !values.empty?
        @data ||= {}
        
        if !block_given && !values_given
          @data[meth] = Outline.new(parent: self) unless @data.has_key?(meth)
          
          @data[meth]
        elsif block_given && values_given
          data = values.delete_at(-1) if values.last.respond_to?(:to_hash) || values.last.respond_to?(:to_h)
          data = { value: values.length == 1 ? values.first : values }.merge!(data || {})
          
          @data[meth] = Outline.new(parent: self, data: data, &blk)
        elsif !block_given && values_given
          data = values.delete_at(-1) if values.last.respond_to?(:to_hash) || values.last.respond_to?(:to_h)
          
          if data.nil?
            @data[meth] = values.length == 1 ? values.first : values
          else
            data = { value: values.length == 1 ? values.first : values }.merge!(data || {}) unless values.empty?
            
            @data[meth] = Outline.new(parent: self, data: data)
          end
        elsif block_given && !values_given
          @data[meth] = Outline.new(parent: self, &blk)
        end
      end
      
      meta_def("#{meth}=") { |value| __send__(meth, value) }
    end
    
    __send__(meth, *args, &blk)
  end
  
  def each
    to_h.each { |k, v| yield(k, v) }
  end
  
  def to_h
    @data ||= {}
    @data.each_with_object({}) do |(key, value), memo|
      memo[key] = value.respond_to?(:to_h) ? value.to_h : value
    end
  end
  
  # def to_json; end
  # def to_xml; end
  # def to_yaml; end
end
