class ChatService
  # List available chats
  def index(params, token)
    # Handle pagination
    page = params[:page] || 1
    per_page = params[:per_page] || 20

    # Check that the current application is correct
    application = Application.where(token: token).first

    if !application
      return
    end

    return Chat.where(application_id: application[:id]).limit(per_page.to_i).offset((page.to_i - 1) * per_page.to_i)
  end

  # Create new chat
  def create(data)
    application = Application.where(token: data[:application_id]).first

    # Get last chat number to insert
    chat_number = 1
    REDIS_CLIENT.watch("application_#{application[:id]}_next_chat_number") do
      chat_number = REDIS_CLIENT.get("application_#{application[:id]}_next_chat_number").to_i
      
      REDIS_CLIENT.set("application_#{application[:id]}_next_chat_number", chat_number+1)

      REDIS_CLIENT.unwatch
    end

    # Check if needing to create a new jon to insert in database
    REDIS_CLIENT.watch("application_#{application[:id]}_last_create_job_date") do
      last_job_date = REDIS_CLIENT.get("application_#{application[:id]}_last_create_job_date").to_i
      
      if Time.now.to_i - last_job_date >= 10
        InsertChatsJob.set(wait: 10.seconds).perform_later(application[:id])

        REDIS_CLIENT.set("application_#{application[:id]}_last_create_job_date", 10.seconds.after.to_i)
      end

      REDIS_CLIENT.unwatch
    end

    # store new chat object in redis
    REDIS_CLIENT.watch("application_#{application[:id]}_pending_chats_to_create") do
      old_chats = REDIS_CLIENT.get("application_#{application[:id]}_pending_chats_to_create")

      old_chats = ActiveSupport::JSON.decode(old_chats)

      old_chats.push({
        number: chat_number,
        creator: data[:creator]
      })

      new_chats = ActiveSupport::JSON.encode(old_chats)

      REDIS_CLIENT.set("application_#{application[:id]}_pending_chats_to_create", new_chats)
      
      REDIS_CLIENT.unwatch
    end
    
    return [
      number: chat_number
    ]
  end

  # Update specific chat
  def update(data, id)
    # Check that the current application is correct
    application = Application.where(token: data[:application_id]).first

    if !application
      return
    end
    
    # Check that the current chat to update is correct
    chat = Chat.where(number: id).where(application_id: application[:id]).first

    if !chat
      return
    end

    # Check if needing to create a new job to update in database
    REDIS_CLIENT.watch("application_#{application[:id]}_last_update_job_date") do
      last_job_date = REDIS_CLIENT.get("application_#{application[:id]}_last_update_job_date").to_i
      
      if Time.now.to_i - last_job_date >= 10
        UpdateChatsJob.set(wait: 10.seconds).perform_later(application[:id])

        REDIS_CLIENT.set("application_#{application[:id]}_last_update_job_date", 10.seconds.after.to_i)
      end

      REDIS_CLIENT.unwatch
    end

    # store updated chat object in redis to be persist in main database soon
    REDIS_CLIENT.watch("application_#{application[:id]}_pending_chats_to_update") do
      old_chats = REDIS_CLIENT.get("application_#{application[:id]}_pending_chats_to_update")

      old_chats = ActiveSupport::JSON.decode(old_chats)

      old_chats.push({
        id: chat[:id],
        creator: data[:creator]
      })

      new_chats = ActiveSupport::JSON.encode(old_chats)

      REDIS_CLIENT.set("application_#{application[:id]}_pending_chats_to_update", new_chats)
      
      REDIS_CLIENT.unwatch
    end
  end
end