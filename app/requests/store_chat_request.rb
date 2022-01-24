class StoreChatRequest
    def initialize(data)
      @data = data
    end

    def validate
        if !@data[:application_id]
            return "please select specific application"
        end

        if !@data[:creator]
            return "please enter creator name"
        end

        if !Application.where(token: @data[:application_id]).first
            return "please select valid application"
        end
    end
end