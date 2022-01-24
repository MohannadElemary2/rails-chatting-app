class ListChatsRequest
    def initialize(data)
      @data = data
    end

    # Validate request inputs
    def validate
        if !@data[:application_id]
            return "please choose specific application"
        end
    end
end