class ApplicationController < ActionController::API
    include Response

    def initialize
        @service = ApplicationService.new
    end

    def index
        applications = @service.index(params)

        send_success_response(
            'success',
            ApplicationTransformer.new(applications).transform
        )
    end

    def create
        error_message = StoreApplicationRequest.new(params).validate()
        
        if error_message
            send_error_response(error_message)
            return
        end

        application = @service.create(params)

        send_success_response(
            'success',
            ApplicationTransformer.new(application).transform,
            :created
        )
    end

    def update
        error_message = UpdateApplicationRequest.new(params).validate()
        
        if error_message
            send_error_response(error_message)
            return
        end

        @service.update(params, params[:id])

        send_success_response('success')
    end
end
