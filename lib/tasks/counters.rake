namespace :counters do
  desc "Calculate count of applications/chats"
  task recalculate_applications_count: :environment do
    applications = Application.where(has_new_chats: 1)

    applications.each do |application|
      chats_count = Chat.where(application_id: application[:id]).count
      application.update(has_new_chats: 0, chats_count: chats_count)
    end
  end

  task recalculate_chats_count: :environment do
    chats = Chat.where(has_new_messages: 1)

    chats.each do |chat|
      messages_count = Message.where(chat_id: chat[:id]).count
      chat.update(has_new_messages: 0, messages_count: messages_count)
    end
  end
end
