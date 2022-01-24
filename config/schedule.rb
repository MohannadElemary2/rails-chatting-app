every 1.hour do
    rake "counters:recalculate_applications_count"
end

every 1.hour do
    rake "counters:recalculate_chats_count"
end