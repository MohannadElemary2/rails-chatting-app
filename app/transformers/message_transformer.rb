class MessageTransformer
    def initialize(data)
        @data = data
    end

    # Trasform (map) the response data
    def transform
        result = []

        if @data.respond_to?("each")
            @data.each do |element|
                result.push({
                    creator: element[:creator],
                    body: element[:body],
                    number: element[:number]
                })
            end
        elsif @data
            result.push({
                creator: @data[:creator],
                body: @data[:body],
                number: element[:number]
            })
        end

        return result
    end
end
