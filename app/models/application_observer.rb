class ApplicationObserver < ActiveRecord::Observer
    # Observe creating applications to insert necessary keys for
    # this application in redis
    def after_create(application)
        # To indicate the next created chat number
        REDIS_CLIENT.set("application_#{application[:id]}_next_chat_number", 1)

        # To indicate the execution time of chat's creation job
        REDIS_CLIENT.set("application_#{application[:id]}_last_create_job_date", 10.seconds.ago.to_i)
        # To indicate the execution time of chat's updating job
        REDIS_CLIENT.set("application_#{application[:id]}_last_update_job_date", 10.seconds.ago.to_i)
        
        # To store the new created chats in this application
        REDIS_CLIENT.set("application_#{application[:id]}_pending_chats_to_create", '[]')
        # To store the updated chats in this application
        REDIS_CLIENT.set("application_#{application[:id]}_pending_chats_to_update", '[]')
    end
end