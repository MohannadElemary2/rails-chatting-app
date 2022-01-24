class UpdateApplicationRequest
    def initialize(data)
      @data = data
    end

    # Validate request inputs
    def validate
        if !@data[:name]
            return "please enter application name"
        end
    end
end