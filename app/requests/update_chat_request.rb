class UpdateChatRequest
    def initialize(data)
      @data = data
    end

    # Validate request inputs
    def validate
        if !@data[:creator]
            return "please enter creator name"
        end
    end
end