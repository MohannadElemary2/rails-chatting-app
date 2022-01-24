class ApplicationService
  # List available applications
  def index(params)
    # Handle pagination
    page = params[:page] || 1
    per_page = params[:per_page] || 20

    return Application.limit(per_page.to_i).offset((page.to_i - 1) * per_page.to_i)
  end

  # Create new application
  def create(data)
    # Generate new application token
    data[:token] = (0...50).map { ('a'..'z').to_a[rand(26)] }.join
    
    return Application.create(
      data.permit(:name, :token, :creator)
    )
  end

  # Update specific application
  def update(data, token)
    Application.where(token: token).update_all(name: data[:name])
  end
end