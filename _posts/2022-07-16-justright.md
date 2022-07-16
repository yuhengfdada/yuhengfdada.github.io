---
title: Software Engineering: What is "Just Right"?
categories:
  - Blog
tags:
  - Thoughts
  - Software Engineering
---

# Lessons Learned

## Preassumption: Think about every case that can lead to a failure

## IMPORTANT: Know the numbers

## Most of the time, brute force is enough

## If you are proposing a change, make sure you understand the trade-offs

### If you are proposing an improvement, make sure it's worth improving

In my previous project, every minute a new goroutine will be spawned to run the same worker function. As it's the same function, they R&W the same states so we were worried about what if the previous run was too slow (it involves DB ops) that it runs over 1 min and the second run will run concurrently with it. We proposed to use a lock over the key state to protect it.

Our mentor suggests that we can avoid this locking complexity. Currently, the computation is fast enough to complete in ~10s. Moreover, we have operation timeouts for DB, so the 1 minute interval is not very likely to timeout.

# Conclusion

First step: Think of every possible problem of your software. This makes sure your program is correct, and that's the most important thing.

Second step: If you think you spotted a problem, think: 

1. Is this really a problem? Is there really a need to fix it? Probably even if the "problem" happens, the users just doesn't care, or we can quickly recover.

2. how possible is this going to happen? Can we reduce the possibility so that the users won't care about the problem?

Third step: Okay, it's really a problem. You will propose changes to fix it. Then think of the trade-offs.



Next is an example (a project I'm working on) of the above principles.

# Problem to Solve

Traders want to see real-time unrealized PNL, which can be calculated using: 1. The current inventory (open position) information; 2. The current market quotes (prices) of these open positions.

# Approach

We have two goroutines, one subscribing to the inventory updates, one subscribing to quote updates. Once they received such update, they will first do some preprocessing (like convert minor currency to major) and push this event to a go channel.

The main goroutine will keep receiving events from the channel. It will keep (cache) two states: 1. Inventory; 2. Quotes, and on every event arrival, use the latest states to calculate the current unrealized PNL.

// To insert a diagram here

# Questions Raised

## The Busy Main & Channel Overflow

We know that quotes arrive very frequently (know your numbers!). If we are pushing every quote update into the channel, firstly if the calculation in Main takes longer than the interval that quotes arrive, the channel will eventually overflow. Moreover, if more than one quote on the same symbol are queued in the channel, the Main will first do calculation on the old quote (channel is FIFO), resulting in wasted calculation.

We suggest that we can just put the latest quote somewhere else, and the Main will read from it from time to time.

However, this solution faces concurrency problem. If we are storing it at some shared variable (like a map), there will be races.

If we are storing in like, Redis, we add complexity.

Our mentor suggests that we can just throttle on sending the quotes to the channel. That is, we only send the quotes to the channel from time to time. The interval will depend on the requirements from the business, and how fast Main can handle the events.

## Lost Messages

We are using Solace direct messaging to pass the inventory and quotes. Direct messaging means if a message arrives but there's no one to consume, it will just disappear.

There is also persistent messaging, but the team decided the messages we're using needn't to be persisted. (If a message need to be persisted, it will be pushed to Redis stream)

As mentioned, the subscribing goroutine will do some preprocessing on receiving an event, and during the time the goroutine will not be able to receive messages. This will cause the message to be lost.

We suggested to open a new goroutine to do the preprocessing, so that the subscriber goroutine can continue receiving messages.

However, we didn't think of the numbers.

1. The preprocessing is very simple and only takes some nanoseconds. The overhead of creating a goroutine is probably more...
2. We don't care if we miss some messages on quotes, because it will be updated very often. We do want to receive every inventory updates, but they don't trade that often, so it's almost impossible for any message to arrive exactly during the preprocessing step.
3. Our mentor said Solace direct messaging has buffers.
