class ChatTransformer
    def initialize(data)
        @data = data
    end

    # Trasform (map) the response data
    def transform
        result = []

        if @data.respond_to?("each")
            @data.each do |element|
                result.push({
                    number: element[:number]
                })
            end
        elsif @data
            result.push({
                number: @data[:number]
            })
        end

        return result
    end
end
