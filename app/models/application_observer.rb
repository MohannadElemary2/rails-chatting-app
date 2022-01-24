class ApplicationObserver < ActiveRecord::Observer
    def after_create(application)
        REDIS_CLIENT.set("application_#{application[:id]}_next_chat_number", 1)

        REDIS_CLIENT.set("application_#{application[:id]}_last_create_job_date", 10.seconds.ago.to_i)
        REDIS_CLIENT.set("application_#{application[:id]}_last_update_job_date", 10.seconds.ago.to_i)
        
        REDIS_CLIENT.set("application_#{application[:id]}_pending_chats_to_create", '[]')
        REDIS_CLIENT.set("application_#{application[:id]}_pending_chats_to_update", '[]')
    end
end