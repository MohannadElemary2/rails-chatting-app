class ApplicationService
  def index(params)
    page = params[:page] || 1
    per_page = params[:per_page] || 20

    return Application.limit(per_page.to_i).offset((page.to_i - 1) * per_page.to_i)
  end

  def create(data)
    data[:token] = (0...50).map { ('a'..'z').to_a[rand(26)] }.join
    
    return Application.create(
      data.permit(:name, :token, :creator)
    )
  end

  def update(data, token)
    Application.where(token: token).update_all(name: data[:name])
  end
end