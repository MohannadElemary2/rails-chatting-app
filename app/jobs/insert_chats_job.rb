class InsertChatsJob < ApplicationJob
  queue_as :chats

  # Insert bulk chats
  def perform(*data)
    application_id = data[0]
    chats = []
    
    # Get new stored chats from redis to be stored in the main database
    REDIS_CLIENT.watch("application_#{application_id}_pending_chats_to_create") do
      chats = REDIS_CLIENT.get("application_#{application_id}_pending_chats_to_create")

      chats = ActiveSupport::JSON.decode(chats)

      REDIS_CLIENT.set("application_#{application_id}_pending_chats_to_create", '[]')
      
      REDIS_CLIENT.unwatch
    end

    # Append chats' application id
    chats.each do |element|
      element[:application_id] = application_id
    end

    # Create bulk
    Chat.create(chats)

    # Mark the chat's application as having new 
    # chats (so the count be updated with the next cron job)
    Application.where(id: application_id).update_all(has_new_chats: 1)
  end
end
