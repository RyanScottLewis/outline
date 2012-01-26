require 'bundler/setup'
require 'meta_tools'

class Hash
  def to_outline
    
  end
end

class Outline
  class ArgumentWithBlockError < StandardError
    def to_s; "You cannot give an argument with a block"; end
  end
  
  include MetaTools
  
  attr_reader :parent, :data
  
  def initialize(opts={}, &blk)
    raise(TypeError, "opts must respond to :to_hash or be nil") unless opts.nil? || opts.respond_to?(:to_hash)
    raise(TypeError, "opts[:data] must respond to :to_h or :to_hash or be nil") unless opts.nil? || opts.respond_to?(:to_hash) || opts.respond_to?(:to_h)
    
    opts = opts.to_hash
    
    # Check to see if incoming data is already an outline
    # if so, then turn it into a hash
    
    data = opts[:data].respond_to?(:to_hash) ? opts[:data].to_hash : opts[:data].to_h unless opts[:data].nil? || opts[:data].is_a?(Outline)
    
    @parent = opts[:parent]
    @data = data
    
    instance_eval(&blk) if block_given?
  end
  
  def method_missing(meth, *args, &blk)
    meth = meth.to_s.gsub(/=$/, '').to_sym if meth =~ /=$/
    
    meta_def(meth) do |value=nil, &blk|
      block_given, value_given = !blk.nil?, !value.nil?
      @data ||= {}
      
      if !block_given && !value_given
        @data[meth] = Outline.new(parent: self) unless @data.has_key?(meth)
        
        @data[meth]
      elsif block_given && value_given
        raise ArgumentWithBlockError
      elsif !block_given && value_given
        @data[meth] = value
      elsif block_given && !value_given
        @data[meth] = Outline.new(parent: self, &blk)
      end
      
    end unless methods.include?(meth)
    
    meta_def("#{meth}=") { |value| send(meth, value) }
    
    send(meth, *args, &blk)
  end
  
  def to_h
    @data.inject({}) do |memo, (key, value)|
      memo[key] = value#.respond_to?(:to_h) ? value.to_h : value
      memo
    end
  end
  
  def inspect
    # "#<Outline:0x#{self.object_id.to_s(16)} @data=#{to_h}>"
    "{O}#{to_h}"
  end
  
  # def to_json; end
  # def to_xml; end
  # def to_yaml; end
end
