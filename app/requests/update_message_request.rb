class UpdateMessageRequest
    def initialize(data)
      @data = data
    end

    # Validate request inputs
    def validate
        if !@data[:creator]
            return "please enter creator name"
        end

        if !@data[:body]
            return "please enter the message"
        end
    end
end