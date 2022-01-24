
## Introduction

This repository introduces a simple ruby on rail application for chat messaging. User is able to create new application, a new chat within a specific application, and a new messages within a chat.

<br />

Elasticsearch is used to retreive chat messages when requested. N-gram analyzer is used in order to give ability for partially searching in messages body.

<br />

The creation of messages and chats is not done directly to the main database. Instead, it's being queued and inserted in bulk with one query to reduce database hits.

  

## Postman Collection

[Click here](https://documenter.getpostman.com/view/8868758/UVXqFYiX)

## Todo
- Cache applications and chats in redis in order to reduce database hits more.
- Update messages in elasticsearch when it's updated in main database