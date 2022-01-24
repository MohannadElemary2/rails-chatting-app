class StoreApplicationRequest
    def initialize(data)
      @data = data
    end

    # Validate request inputs
    def validate
        if !@data[:name]
            return "please enter application name"
        end

        if !@data[:creator]
            return "please enter creator name"
        end
    end
end