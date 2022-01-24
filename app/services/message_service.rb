class MessageService
  # List message using elasticsearch
  def index(params)
    # Handle pagination
    page = params[:page] || 1
    per_page = params[:per_page] || 20

    # Check that the current application is correct
    application = Application.where(token: params[:application_id]).first

    if !application
      return
    end

    # Check that the current chat is correct
    chat = Chat.where(number: params[:chat_id]).where(application_id: application[:id]).first

    if !chat
      return
    end

    # Prepare elasticsearch query
    elastic_obj = {
      from: (page.to_i - 1) * per_page.to_i,
      size: per_page.to_i,
      query: {
        bool: {
          filter: [
            {term: {chat_id: chat[:id]}}
          ]
        }
    }}

    # Add search by message body if requested
    if params[:q]
      elastic_obj[:query][:bool][:must] = { match: { body: params[:q]}}
    end

    messages = ELASTIC_SEARCH_REPOSITORY.search(elastic_obj)

    return messages
  end

  # Create new message
  def create(data)
    application = Application.where(token: data[:application_id]).first

    if !application
      return
    end

    chat = Chat.where(number: data[:chat_id]).where(application_id: application[:id]).first

    if !chat
      return
    end

    # Get last message number to insert
    message_number = 1
    REDIS_CLIENT.watch("chat_#{chat[:id]}_next_message_number") do
      message_number = REDIS_CLIENT.get("chat_#{chat[:id]}_next_message_number").to_i

      if message_number == 0
        message_number = 1
      end
      
      REDIS_CLIENT.set("chat_#{chat[:id]}_next_message_number", message_number+1)

      REDIS_CLIENT.unwatch
    end

    # Check if needing to create a new job to insert in database
    REDIS_CLIENT.watch("chat_#{chat[:id]}_last_create_job_date") do
      last_job_date = REDIS_CLIENT.get("chat_#{chat[:id]}_last_create_job_date").to_i

      last_job_date = last_job_date || 0
      
      if Time.now.to_i - last_job_date >= 10
        InsertMessagesJob.set(wait: 10.seconds).perform_later(chat[:id])

        REDIS_CLIENT.set("chat_#{chat[:id]}_last_create_job_date", 10.seconds.after.to_i)
      end

      REDIS_CLIENT.unwatch
    end

    # store new message object in redis
    REDIS_CLIENT.watch("chat_#{chat[:id]}_pending_messages_to_create") do
      old_messages = REDIS_CLIENT.get("chat_#{chat[:id]}_pending_messages_to_create")

      old_messages = old_messages || '[]'

      old_messages = ActiveSupport::JSON.decode(old_messages)

      old_messages.push({
        number: message_number,
        creator: data[:creator],
        body: data[:body]
      })

      new_messages = ActiveSupport::JSON.encode(old_messages)

      REDIS_CLIENT.set("chat_#{chat[:id]}_pending_messages_to_create", new_messages)
      
      REDIS_CLIENT.unwatch
    end
    
    return [
      number: message_number,
      creator: data[:creator],
      body: data[:body]
    ]
  end

  # Update specific message
  def update(data, id)
    application = Application.where(token: data[:application_id]).first

    if !application
      return
    end
    
    chat = Chat.where(number: data[:chat_id]).where(application_id: application[:id]).first

    if !chat
      return
    end

    message = Message.where(chat_id: chat[:id]).where(number: data[:id]).first

    if !message
      return
    end

    # Check if needing to create a new jon to update in database
    REDIS_CLIENT.watch("chat_#{chat[:id]}_last_update_job_date") do
      last_job_date = REDIS_CLIENT.get("chat_#{chat[:id]}_last_update_job_date").to_i
      
      last_job_date = last_job_date || 0

      if Time.now.to_i - last_job_date >= 10
        UpdateMessagesJob.set(wait: 10.seconds).perform_later(chat[:id])

        REDIS_CLIENT.set("chat_#{chat[:id]}_last_update_job_date", 10.seconds.after.to_i)
      end

      REDIS_CLIENT.unwatch
    end

    # store new message object in redis
    REDIS_CLIENT.watch("chat_#{chat[:id]}_pending_messages_to_update") do
      old_messages = REDIS_CLIENT.get("chat_#{chat[:id]}_pending_messages_to_update")

      old_messages = old_messages || "[]"

      old_messages = ActiveSupport::JSON.decode(old_messages)

      old_messages.push({
        id: message[:id],
        creator: data[:creator],
        body: data[:body]
      })

      new_messages = ActiveSupport::JSON.encode(old_messages)

      REDIS_CLIENT.set("chat_#{chat[:id]}_pending_messages_to_update", new_messages)
      
      REDIS_CLIENT.unwatch
    end
  end
end
