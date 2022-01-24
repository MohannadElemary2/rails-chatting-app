class UpdateMessagesJob < ApplicationJob
  queue_as :messages

  def perform(*data)
    chat_id = data[0]
    messages = []
    
    REDIS_CLIENT.watch("chat_#{chat_id}_pending_messages_to_update") do
      messages = REDIS_CLIENT.get("chat_#{chat_id}_pending_messages_to_update")

      messages = ActiveSupport::JSON.decode(messages)

      REDIS_CLIENT.set("chat_#{chat_id}_pending_messages_to_update", '[]')
      
      REDIS_CLIENT.unwatch
    end

    messages.each do |element|
      Message.where(id: element["id"]).update_all(creator: element["creator"], body: element["body"])
    end
  end
end
