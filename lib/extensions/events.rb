# @private
module Events

  def self.included(base)
    base.extend(ClassMethods)
  end
  
  # @return [Boolean] If the event has a handler registered
  def has_event_handler?(event)
    @events ||= {}
    !@events["on_#{event}".to_sym].nil?
  end
  
  module ClassMethods

    # @param [Array<String, Symbol>] events Array of event names
    # @example
    #   has_events :delete, :create
    def has_events(*events)
      events.map { |event| event.to_s }.each do |event|
        self.class_eval <<-"END"
          def on_#{event}(*args, &block)
            @events ||= {}
            if block_given? then
              @events[:on_#{event}] = block.to_proc              
            else
              @events[:on_#{event}].call(*args) unless @events[:on_#{event}].nil?
            end
            return self
          end
        END
      end
    end

    def has_event(event)
      has_events(*[event])
    end

  end
  
end