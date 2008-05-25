module Templater
  class Template
  
    attr_accessor :context, :name, :source, :destination
  
    def initialize(context, name, source, destination)
      @context = context
      @name = name
      @source = source
      @destination = destination
    end
  
    # Renders the template, and returns the result as a string
    def render
      ERB.new(File.read(source)).result(context.send(:binding))
    end

    # returns true if the destination file exists.
    def exists?
      File.exists?(destination)
    end
  
    # returns true if the content of the file at the destination are identical to the rendered result.
    def identical?
      File.read(destination) == render if File.exists?(destination)
    end
  
    # Renders the template and copies it to the destination
    def invoke!
      File.open(destination, 'w') {|f| f.write render }
    end
  
  end
end