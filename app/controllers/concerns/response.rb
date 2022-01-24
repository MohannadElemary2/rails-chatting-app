module Response
    def send_success_response(message, data = [], status = :ok)
        render json: {
            message: message,
            data: data,
            success: 1
        }, status: status
    end

    def send_error_response(message, errors = [], status = :bad_request)
        render json: {
            message: message,
            errors: errors,
            success: 0
        }, status: status
      end
end