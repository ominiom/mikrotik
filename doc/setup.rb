class HasEventsHandler < YARD::Handlers::Ruby::Base
  handles method_call(:has_events)
  handles method_call(:has_event)
  namespace_only

  def process
    name = statement.parameters.select { |p|
      p.kind_of?(YARD::Parser::Ruby::AstNode)
    }.each { |event_name|
      event_name = event_name.jump(:ident).source
      object = YARD::CodeObjects::MethodObject.new(namespace, "on_#{event_name}")
      # object.docstring = statement.comments || ''
      register(object) 
      object.dynamic = true
      object.docstring.add_tag(YARD::Tags::Tag.new(:return, 'self', namespace.path))
      object.docstring.add_tag(YARD::Tags::Tag.new(:group, 'Events'))      
      puts object.tags.inspect
    }    
  end
end
