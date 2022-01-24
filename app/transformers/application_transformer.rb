class ApplicationTransformer
    def initialize(data)
        @data = data
    end

    def transform
        result = []

        if @data.respond_to?("each")
            @data.each do |element|
                result.push({
                    name: element[:name],
                    token: element[:token],
                })
            end
        elsif @data
            result.push({
                name: @data[:name],
                token: @data[:token]
            })
        end

        return result
    end
end
