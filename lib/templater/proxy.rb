module Templater
  
  class Proxy #:nodoc:
    
    def initialize(name, source, destination, &block)
      @block, @source, @destination = block, source, destination
      @name = name.to_sym
    end
    
    def source(source)
      @source = source
    end
    
    def destination(dest)
      @destination = dest
    end
    
    def method_missing(method, *args, &block)
      if @generator
        @generator.send(method, *args, &block)
      else
        super
      end
    end
    
    protected
    
    def get_source
      ::File.expand_path(@source.to_s, @generator.source_root)
    end
    
    def get_destination
      ::File.expand_path(convert_encoded_instructions(@destination.to_s), @generator.destination_root)
    end
    
    def convert_encoded_instructions(filename)
      filename.gsub(/%.*?%/) do |string|
        instruction = string.match(/%(.*?)%/)[1]
        @generator.respond_to?(instruction) ? @generator.send(instruction) : string
      end
    end
    
  end
  
  class TemplateProxy < Proxy #:nodoc:
    
    def to_template(generator)
      @generator = generator
      instance_eval(&@block) if @block
      Templater::Template.new(generator, @name, get_source, get_destination)
    end
    
  end
  
  class FileProxy < Proxy #:nodoc:
    
    def to_file(generator)
      @generator = generator
      instance_eval(&@block) if @block
      @generator = nil
      Templater::File.new(@name, ::File.join(generator.source_root, @source.to_s), ::File.join(generator.destination_root, @destination.to_s))
    end
    
  end
  
end