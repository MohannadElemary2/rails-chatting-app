class UpdateChatsJob < ApplicationJob
  queue_as :chats

  # Update bulk chats
  def perform(*data)
    application_id = data[0]
    chats = []
    
    # Get updated chats from redis to be stored in the main database
    REDIS_CLIENT.watch("application_#{application_id}_pending_chats_to_update") do
      chats = REDIS_CLIENT.get("application_#{application_id}_pending_chats_to_update")

      chats = ActiveSupport::JSON.decode(chats)

      REDIS_CLIENT.set("application_#{application_id}_pending_chats_to_update", '[]')
      
      REDIS_CLIENT.unwatch
    end

    # Start updating
    chats.each do |element|
      Chat.where(id: element["id"]).update_all(creator: element["creator"])
    end
  end
end
