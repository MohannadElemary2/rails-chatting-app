class StoreMessageRequest
    def initialize(data)
      @data = data
    end

    # Validate request inputs
    def validate
        if !@data[:chat_id]
            return "please select specific chat"
        end

        if !@data[:creator]
            return "please enter creator name"
        end

        if !@data[:body]
            return "please enter the message"
        end

        if !Chat.where(number: @data[:chat_id]).first
            return "please select valid chat"
        end
    end
end