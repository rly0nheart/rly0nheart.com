---
author: Ritchie
date: 2026-06-07T10:00:00+02:00
title: Gooeys (GUIs) Might Not Be My Thing
categories:
  - programming
  
tags:
  - learning
  - python
  - ai
---

I'm starting to realise that I might not be very interested in building GUIs. They take too much time, and when the project already has a CLI and a library, the GUI always ends up feeling like a whole separate job on its own. Though I think this is mostly a solo developer problem. When there's a team behind it, you can at least split responsibilities and have different people working on different parts of the project.

Bear with me, this is not laziness :D. I love coding. But I've come to realise that I enjoy developing CLI, TUI or "barebones" apps way more than GUI apps, and I think I'm finally starting to understand why.

I'm just not a great UX designer. When I'm working on a GUI or anything with visual styling involved, I always end up making it appealing to me, not to whomever might come to use it. But when I'm working on TUI or CLI tools, I actually care about making sure the user has a nice experience and that the whole thing is easy to use.

I only realised this after I vibe-coded a [GTK4 app](https://github.com/rly0nheart/buganize/tree/master/src/buganize/gui) for [buganize](https://github.com/rly0nheart/buganize)[^1]. I haven't even pushed more than 2 (or 3?) commits to it [the gooey], but I already feel like it's draining. I was actually thinking about hunting for bugs in buganize[^2], and the thought of the GUI existing just kind of killed my motivation. Like I don't have time for it.

And honestly, AI is making prototyping faster and easier, but it's also increasing the number of unnecessary apps being built. The buganize GUI is a good example of that. It exists, but it doesn't really need to. So I'm probably pulling it from future releases, and going forward I might just stay away from GUI projects unless I'm trying to solve a real problem.


[^1]: Buganize is basically a product of a lightly reverse-engineered API of Google's Issue Tracking system... Buganizer (story for another day).

[^2]: Yes...
