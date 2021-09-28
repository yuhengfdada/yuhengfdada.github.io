---
title: "What I learned in Alibaba"
categories:
  - Blog
tags:
  - Thoughts
  - Software Engineering
---

I joined the DingTalk division of Alibaba Group as an intern at the beginning of August. I "formally" started learning computer science in December last year (how I learned CS will hopefully be updated in a later post) and I didn't have **any** internship on my resume, so I honestly didn't expect they would accept me. But anyway, they did. I'd say I performed adequately in the interview; I got most of the technical questions right (fortunately they weren't too harsh on LeetCode questions). I remember I "introduced" Raft to a P9 during my second interview and said I was *going to* read `Designing Data-Intensive Applications`. It turned out that I didn't read a page of it after I started my internship, and here's why.

On the second day I was thrown into piles of production code. My mentor said they expect interns to start working immediately. I replied: "Okay. *But how do I set up Maven?* " 

So I rushed the entire development stack in my first month, including the basics of Java (I used `Thinking in Java`), Spring(Boot), Most of the Alibaba middlewares, Design Patterns and Refactoring (you know which two books i am talking about), and of course, Maven (it was actually the easiest of them).

But these are not that important. I can read book and learn all these without doing an internship at all. Here are some of the things I want to highlight during my days at Alibaba:

## Understanding Code

I probably read the largest amount of code in my life during the past two months, and I realized "reading" code has nothing in common with reading a book. 

- **Don't try to understand everything.** Actually, you can't. Just read what you have to read, e.g. these related to your current work. Your new functionality might involve 3 other applications. Only read the code that's relevant. 
- **But make sure you understand the details (of the code you have to read).** 
  - When following a function call chain, you will run out of brain cache. Take notes if necessary. 
  - A particular good method is to log down (in your code) the key data objects and see how these functions changed them. A key data object is typically an input or an output of a key function.
  - Use your IDE well. I particularly like `Find usages` and `Hierarchy(control+oprion+H)` in IntelliJ. 
- **Write code that is easy to understand.** We have coding rules that specifies how to name a variable and such. I *really* appreciated it that most of us followed them.

##  DevOps

CI/CD is good. Just feels so nice to have a CI/CD platform. Release stages are clear and everything is under control.

Test and test. Unit test. Functional test. Code review. Integration test. Regression test. That's what I call risk management.

Log is God. I can't remember how many times I resorted to logs. Use your `grep` and `tail -f` well. Probably you also want `tail -f | grep --line-buffered`.

##  Communication

I had been self-studying for months and I always thought I could solve everything by myself (in fact, by the Internet). Therefore, during my very first Alibaba days, I tried to read code without asking any questions (partly it was because everyone seemed so busy). BUT I JUST COULDN'T UNDERSTAND.

In retrospect, it was because there was so much business logic and data objects that I couldn't possibly understand without asking my collegues.

So gradually I started asking. I would say things got much better.

