class ApplicationController < ActionController::API
    include Response

    def initialize
        @service = ApplicationService.new
    end

    # List applications
    def index
        applications = @service.index(params)

        send_success_response(
            'success',
            ApplicationTransformer.new(applications).transform
        )
    end

    # Create new application
    def create
        # Validate inputs
        error_message = StoreApplicationRequest.new(params).validate()
        
        if error_message
            send_error_response(error_message)
            return
        end

        # Store application data
        application = @service.create(params)

        # Return response with create application data
        send_success_response(
            'success',
            ApplicationTransformer.new(application).transform,
            :created
        )
    end

    # Update application
    def update
        # Validate inputs
        error_message = UpdateApplicationRequest.new(params).validate()
        
        if error_message
            send_error_response(error_message)
            return
        end

        # Update application data
        @service.update(params, params[:id])

        send_success_response('success')
    end
end
