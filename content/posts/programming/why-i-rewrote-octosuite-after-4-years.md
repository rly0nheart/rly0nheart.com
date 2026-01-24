---
author: Ritchie
date: 2026-01-22T10:23:00+02:00
lastMod: 2026-01-23T01:10:00+02:00
title: Why I Rewrote Octosuite After 4 Years
categories:
  - Programming
tags:
  - Python
  - Learning
---

In case you don't already know, Octosuite is a GitHub OSINT (Open Source Intelligence) framework. Basically a tool that helps investigators, journalists, and researchers dig into publicly available GitHub data. It can pull information on users, repositories, organisations, and more, making it easier to investigate accounts and understand what's happening on the platform.

I built the first 'production-ready' version sometime around 2022 during my internship at Bellingcat. It worked, people used it, and I was genuinely proud of shipping something functional in an organisation.

## The Original Code

When I first built Octosuite, I wasn't very experienced. I was learning as I went, and my priority was simple: make it work. And it did work. The functionality was there, you could investigate accounts, pull data, export results. Mission accomplished.

But I didn't think much about code quality. Maybe the code was readable in some places, sure, but the structure? That was a different story.

There was no separation of concerns. At all. I had entire modules that existed just for help messages. Actual classes dedicated to displaying help text for different sections of the REPL. That alone should tell you something. But it got worse. I had API calls sitting right in the middle of code that was supposed to be presenting data to users. The "frontend" was making API requests directly. No backend module. No clear line between what fetches data and what displays it. Everything was just... mixed together. The more features I added, the more complex it got.

In my defence, I was inexperienced, and I built the whole thing on an Android phone. *When you're coding on a tiny screen with limited tools, you're not thinking about architecture or best practices or maintainability. You're thinking about making it work, period.*

In the early stages of my internship, I tried to make Octosuite as accessible as possible. And one way of doing that was to write a GUI using tkinter. This was good until I got a PC and noticed that the alignments that looked good on the phone were actually off on a desktop. 
Now I had a new problem: alignment of widgets.[^1]

So then I started working on fixing the alignment issues in the GUI. I was able to fix them, and everything was going *great*, until I realised something:

1. Both the GUI and REPL variants had completely separate ways of fetching data (even though that could've been easily centralised)
2. Because of the separation in API handling, it was a little bit tedious to make backend changes to the GUI that would require a change in the REPL as well.
3. Distributing the GUI binaries was another tedious part of it as I had to manually build each binary on the specific platform, i.e., building a .exe binary had to be done on Windows, a .dmg had to be done on MacOS (This is where Virtual Machines came into play)
4. The REPL was on PyPI, but the GUI wasn't. The initial design flaw made it almost impossible to make the GUI available on PyPI and have it functional.

These changes clearly required me to properly plan so that when I start implementing, there wouldn't be any surprises. So, I began planning... and procrastinating :)

## Coming Back to It

Time went by. I worked on other projects. I got better at programming. I started seeing patterns in what made code maintainable versus what made it a nightmare to work with. I learned about separation of concerns, structure, and why these things actually matter.

When I finally came back to Octosuite and opened that codebase, I just stared at it for a while. It was like looking at something written by a different person. *Did I really think this was okay?* 

The answer was yes, because back then, I didn't know any better. And that's fine. That's how learning works. But now I did know better, and I couldn't just leave it like that.

## Deciding What to Do

Initially, Octosuite was a hybrid of a CLI and REPL, but one of those was badly implemented. So this time, I needed to either properly rewrite the badly implemented part, or just ditch the hybrid all together (keeping it simple and stupid).

My first instinct was to turn it into a proper CLI tool (ditching the REPL). That felt like the 'professional' thing to do since it would make Octosuite very scriptable.

I started planning it out. Mapping commands, thinking through arguments, writing help documentation. This was going to be proper software.

And then life got in the way. Other projects came up, personal stuff happened. The CLI version sat there half-done for months.

When I finally got back to it, something had shifted in my thinking. I looked at my CLI plans and asked myself: *Who is this actually for?*

CLI tools are great if you're a technical person. Technical people love typing commands, piping outputs, scripting everything. But Octosuite wasn't built for tech savvy people, it was built for investigators, journalists, researchers. People who might not spend their day in a terminal. People who just want to investigate a GitHub account without having to memorise command syntax or read through pages of documentation.

A CLI wasn't the answer. Not if I wanted this to be accessible.

## The TUI Approach

That's when I discovered TUIs (Text User Interfaces). Not a full graphical application with windows and buttons, but not a bare command line either. Something in between. Menus you could navigate with arrow keys. Checkboxes you could select. Prompts that actually guide you through what you're doing.

This felt right.

I picked my tools more carefully this time:

1. [Questionary](https://github.com/tmbo/questionary) (which is built on top of prompt-toolkit) for the prompts. 
2. [Rich](https://github.com/textualize/rich) for displaying trees, coloured output, and live statuses. 
2. [Prompt-toolkit](https://github.com/prompt-toolkit/python-prompt-toolkit) for dialogs.

With this, users would: Navigate menus instead of typing commands. Check boxes instead of remembering flags, and have nicer output instead of raw response data. 

Everything the old REPL version could do, but wrapped in an interface that actually makes sense.

Plus, I decided to deprecate the GUI

## Starting Over

Here's the thing: I didn't refactor the old code. I didn't try to fix it piece by piece. I looked at it, considered the effort it would take to untangle everything, and decided to start fresh. Completely from scratch.

It wasn't being dramatic. It genuinely would have taken longer to fix than to rebuild properly. Rewriting Octosuite was cheaper and less time-consuming than refactoring it.

So, this time, I built it right. Functions that do one thing. Variables with meaningful names. Proper separation between the code that talks to the API and the code that displays information. Structure that makes sense. Clean, maintainable code that I could actually be proud of. I also cut out features that were less likely to be used.

## Moral of the Story

Opening those old files and seeing just how far I'd come was surreal. That messy code wasn't written by someone careless or lazy. It was written by someone learning, doing their best with what they knew and the constraints they had. Past me got it working and shipped something useful. That counts for something.

We all write bad code when we're learning. When we're figuring things out. When we're just trying to ship something that works. The question isn't whether you'll write bad code (YOU WILL). The question is whether you come back later, look at it honestly, and have the patience to make it better.

Octosuite started as something I hacked together on a phone during my first internship. Now it's something I'm genuinely proud of, not just because it works, but because it's well-made.

Though let's be honest, I'll probably open this code in a couple of years and think the exact same thing: *Did I really write this?* And that'll be a good sign. It'll mean I'm still learning, still getting better.

I've been working on the cli-tui hybrid locally, but I haven't yet decided if I want to have it in the main code. I'll probably write a post about it if I push the hybrid to GitHub.

If you'd like to see the difference between the legacy and new versions of Octosuite, you can checkout the oldest on the [legacy-history branch](https://github.com/bellingcat/octosuite/tree/legacy-history) on GitHub, and the newest on the [master branch](https://github.com/bellingcat/octosuite/tree/master). Who knows, maybe you'll find something I haven't noticed yet.


[^1]: GUI elements are called Widgets in Tkinter. [This article](https://www.geeksforgeeks.org/python/what-are-widgets-in-tkinter/) on GeeksforGeeks explains is well.