class ChatController < ActionController::API
    include Response

    def initialize
        @service = ChatService.new
    end

    # List chats
    def index
        error_message = ListChatsRequest.new(params).validate()

        if error_message
            send_error_response(error_message)
            return
        end

        chats = @service.index(params, params[:application_id])

        send_success_response(
            'success',
            ChatTransformer.new(chats).transform
        )
    end

    # Create new chat
    def create
        error_message = StoreChatRequest.new(params).validate()
        
        if error_message
            send_error_response(error_message)
            return
        end

        chat = @service.create(params)

        send_success_response(
            'success',
            ChatTransformer.new(chat).transform,
            :created
        )
    end

    # Update chat
    def update
        error_message = UpdateChatRequest.new(params).validate()
        
        if error_message
            send_error_response(error_message)
            return
        end

        @service.update(params, params[:id])

        send_success_response('success')
    end
end
