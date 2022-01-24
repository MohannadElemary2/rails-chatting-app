class InsertChatsJob < ApplicationJob
  queue_as :chats

  def perform(*data)
    application_id = data[0]
    chats = []
    
    REDIS_CLIENT.watch("application_#{application_id}_pending_chats_to_create") do
      chats = REDIS_CLIENT.get("application_#{application_id}_pending_chats_to_create")

      chats = ActiveSupport::JSON.decode(chats)

      REDIS_CLIENT.set("application_#{application_id}_pending_chats_to_create", '[]')
      
      REDIS_CLIENT.unwatch
    end

    chats.each do |element|
      element[:application_id] = application_id
    end

    Chat.create(chats)

    Application.where(id: application_id).update_all(has_new_chats: 1)
  end
end
