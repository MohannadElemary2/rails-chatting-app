class InsertMessagesJob < ApplicationJob
  queue_as :messages

  # Insert bulk messages
  def perform(*data)
    chat_id = data[0]
    messages = []
    
     # Get new stored messages from redis to be stored in the main database
    REDIS_CLIENT.watch("chat_#{chat_id}_pending_messages_to_create") do
      messages = REDIS_CLIENT.get("chat_#{chat_id}_pending_messages_to_create")

      messages = ActiveSupport::JSON.decode(messages)

      REDIS_CLIENT.set("chat_#{chat_id}_pending_messages_to_create", '[]')
      
      REDIS_CLIENT.unwatch
    end

    # Append messages' chat id
    # also, save the message to the elasticsearch
    messages.each do |element|
      element[:chat_id] = chat_id

      ELASTIC_SEARCH_REPOSITORY.save(element)
    end

    # Create bulk
    Message.create(messages)

    # Mark the messages's chat as having new 
    # messages (so the count be updated with the next cron job)
    Chat.where(id: chat_id).update_all(has_new_messages: 1)
  end
end
