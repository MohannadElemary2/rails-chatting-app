class ListChatsRequest
    def initialize(data)
      @data = data
    end

    def validate
        if !@data[:application_id]
            return "please choose specific application"
        end
    end
end