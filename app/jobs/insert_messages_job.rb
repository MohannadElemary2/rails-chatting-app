class InsertMessagesJob < ApplicationJob
  queue_as :messages

  def perform(*data)
    chat_id = data[0]
    messages = []
    
    REDIS_CLIENT.watch("chat_#{chat_id}_pending_messages_to_create") do
      messages = REDIS_CLIENT.get("chat_#{chat_id}_pending_messages_to_create")

      messages = ActiveSupport::JSON.decode(messages)

      REDIS_CLIENT.set("chat_#{chat_id}_pending_messages_to_create", '[]')
      
      REDIS_CLIENT.unwatch
    end

    messages.each do |element|
      element[:chat_id] = chat_id

      ELASTIC_SEARCH_REPOSITORY.save(element)
    end

    Message.create(messages)

    Chat.where(id: chat_id).update_all(has_new_messages: 1)
  end
end
