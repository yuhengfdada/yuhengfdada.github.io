---
title: Learning Redis Streams
categories:
  - Blog
tags:
  - Go
  - Redis
---

## XREAD [COUNT count] [BLOCK milliseconds] STREAMS key [key ...] id [id ...]
Some details: 
1. If COUNT is unset, it reads EVERYTHING.
2. The ID field is an EXCLUSIVE lower bound.
   1. For example: There are messages in the stream "numbers" with id 1-0, 2-0, 3-0. Executing `xread streams numbers 1-0` returns the last 2 messages.
   2. This is to provide convenience to a common operation: Using the last-fetched-msg-id in the ID argument gives messages AFTER the last fetched message. 

## XGROUP CREATE key group id
Just note the ID field. This indicates the **starting point** of the consumer group's stream in the main stream.
You can provide the special `$` id to indicate you want the consumer group to start at the next new message added to the main stream.

## XREADGROUP GROUP group consumer [COUNT count] [BLOCK milliseconds] [NOACK] STREAMS key [key ...] id [id ...]

A consumer group receives everything in the main stream. XREADGROUP is reading messages (or making the messages DELIVERED) from a consumer group's sub-stream (which is just a duplicate of the main stream).

Deliver(from Redis stream to a specific consumer) -> Consume(by consumer) -> ACKnowledge(by consumer)
Note: When a message is delivered but has not been ACKed, it's stored in the consumer's Pending Entries List(PEL). It's removed from the PEL when it's ACKed.

Things to be careful:
1. One of the guarantees of consumer groups is that a given consumer can only see the history of messages that were delivered to it, so **a message has just a single owner**. Except when `XCLAIM`ed.

2. The ID to specify in the STREAMS option when using XREADGROUP can be one of the following two:
- The special `>` ID, which means that the consumer want to receive only messages that were never delivered to any other consumer. It just means, give me new messages.
- Any other ID, that is, 0 or any other valid ID or incomplete ID (just the millisecond time part), will have the effect of returning entries that are **pending** for the consumer sending the command with IDs greater than the one provided. **So basically if the ID is not >, then the command will just let the client access its pending entries**: messages delivered to it, but not yet acknowledged. Note that in this case, both BLOCK and NOACK are ignored.

## Consumer group: Advanced features
### XINFO

### ACK operation & NOACK argument
Messages need to be ACKed to be removed from the consumer's PEL. If you choose the `NOACK` option in `XREADGROUP`, the message is instantly deleted on read.
### XPENDING & XCLAIM
When a consumer fails, other consumers can take on its pending messages to prevent message loss. 
## Inside Redis Streams
Redis streams is implemented using Radix Tree, which is similar to a trie. Because the message IDs often have common prefix, this data structure can save space and search time.
Moreover, subsequent field names are compressed. Because message fields are often the same, this can save space as well.