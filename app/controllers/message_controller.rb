class MessageController < ActionController::API
    include Response

    def initialize
        @service = MessageService.new
    end

    def index
        messages = @service.index(params)

        send_success_response(
            'success',
            MessageElasticTransformer.new(messages).transform
        )
    end

    def create
        error_message = StoreMessageRequest.new(params).validate()
        
        if error_message
            send_error_response(error_message)
            return
        end

        message = @service.create(params)

        send_success_response(
            'success',
            MessageTransformer.new(message).transform,
            :created
        )
    end

    def update
        error_message = UpdateMessageRequest.new(params).validate()
        
        if error_message
            send_error_response(error_message)
            return
        end

        @service.update(params, params[:id])

        send_success_response('success')
    end
end
