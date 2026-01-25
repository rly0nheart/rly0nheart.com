---
author: Ritchie
date: 2025-12-22T23:18:00+02:00
title: Fixing PyCharm's Missing Imports and Linting on Fedora Silverblue
categories:
  - Programming
tags:
  - Python
  - PyCharm
  - Jetbrains
  - Learning
---

I've been running Fedora Silverblue for a while now, and recently, I ran into a simple, yet frustrating issue with PyCharm: 

imports weren't being recognised, and linting wasn't working. If you're experiencing the same problem, here's what was actually wrong and how I fixed it.

Now, before we begin, I think you'll need to understand something (in case you don't already) that I'll reference a fair number of times in this post:

> **A JetBrains Toolbox and a Fedora Toolbox are two completely different things. Additionally, if you're not familiar with the Python ecosystem, I'll also explain what a Python venv is, as it's somewhat similar to a Fedora Toolbox.**

## What is a Python venv?

A Python venv (virtual environment) is an isolated space for your Python project where you can install packages without affecting other projects or your system.

**Think of it like this**:

Imagine you're working on multiple Python projects. Project A depends on package X version 1.0, but Project B depends on package X version 2.0. Without venvs, you'd have a dependency conflict because you have 2 projects that depend on different versions of the same package. A venv is like giving each project its own separate "bag" of packages (dependencies), so they don't interfere with each other.

**Why this matters:**

- Each project can have its own versions of packages
- You won't break other projects by updating packages
- Your system Python stays clean
- You can easily share what packages your project depends on, with others
- It's basically a safe, isolated environment for each project's dependencies

## What is a Fedora Toolbox?

A Fedora Toolbox is like a Python venv, but for your entire system instead of just Python packages. It's an isolated environment on a Fedora system where you can install programs and mess around without affecting your main (host) system.

**Think of it like this**: 

Just like a Python venv lets you install Python packages without breaking other projects, a Fedora Toolbox lets you install any software (editors, compilers, tools) without breaking your main system. Your main computer system (Silverblue) is like a clean, locked-down apartment that stays pristine. The toolbox is like having a garage or workshop attached to that apartment where you can make a mess, install tools, experiment, and if something breaks, you just clean out the garage, and your apartment stays untouched.

**Why this matters:**

- You can install whatever software you want in the toolbox without worrying about breaking your main system
- If something goes wrong in the toolbox, you can just delete it and create a fresh one
- Your main system stays stable and reliable
- You can have multiple toolboxes for different projects (just like you can have multiple Python venvs)
- It's basically a safe playground for doing work, development, or trying out software while keeping your core system protected and unchangeable
- Inside a Fedora Toolbox, you can create multiple Python venvs for your different projects

## What is a JetBrains Toolbox?

A JetBrains Toolbox is an app that manages all your JetBrains programming tools in one place.

**Think of it like this**: 

JetBrains makes a bunch of different code editors for different programming languages (IntelliJ for Java, PyCharm for Python, WebStorm for web development, Rust Rover for Rust etc.). 
Instead of downloading and updating each one separately, the Toolbox is like a launcher and manager for all of them.

**What it does:**

- Shows you all the JetBrains apps you have installed in one window
- Lets you quickly open any project in the right editor with one click
- Automatically updates all your editors for you
- Makes it easy to install new JetBrains tools when you need them
- Keeps track of recent projects across all your editors

In simpler terms: If JetBrains editors are like different power tools (drill, saw, sander), the Toolbox is like...well, a toolbox that organises them all, keeps them maintained, and helps you grab the right tool quickly.

---

## The Problem

My PyCharm installation was done from the [JetBrains Toolbox](https://www.jetbrains.com/toolbox-app/download/).

I downloaded the JetBrains Toolbox archive, extracted it, opened a terminal on the host system in the jetbrains-toolbox directory, then executed the `jetbrains-toolbox` binary... pretty standard stuff.

As of writing, I have PyCharm and Rust Rover on my system, but I've been programming in Rust more than Python. I had noticed that PyCharm was not linting or recognising imports, but that didn't really bother me then because I wasn't actively working on any Python projects. 

But as they say in my native language *"ifishikumana fiiwa"* (literally, *"Only ghosts never meet"* or *"Only the dead never cross paths"*), the time came that I had to deal with this specific problem that I've been ignoring. I've been thinking of working on a TUI for [OctoSuite](https://github.com/bellingcat/octosuite), and I felt that at this point in time, I had some time to properly explore the idea.

I started writing the code, and I noticed the following:

- The editor showed red squiggly lines under all my imports, claiming they didn't exist
- No linting or code analysis was working
- I could install packages in the PyCharm terminal (through the venv), but PyCharm's editor couldn't see the venv

The strange part? My scripts would actually *run* successfully. So, the packages existed in the venv, but the editor was completely blind to it.

> [!Note]
> I haven't had this issue with Rust Rover. I simply just enter a Silverblue toolbox where I installed cargo, then I can run all cargo commands without a problem, and linting works just fine.

---

## First Attempt: Moving Everything to Toolbox

My initial thought was that this was a Silverblue immutability issue. I had PyCharm installed on the host system, and I figured that was causing problems. So I decided to:

1. Completely remove PyCharm and JetBrains Toolbox from my host system (yes, sacrificing Rust Rover in the process)
2. Install everything fresh inside a Fedora Toolbox container

### Cleaning Up the Host

I removed all traces of JetBrains from my host:

> [!Code] Shell
> ```bash
> # Killed running processes (as it was still running)
> pkill -f jetbrains-toolbox
>
> # Removed all data
> rm -rf ~/.local/share/JetBrains
> rm -rf ~/.config/JetBrains
> rm -rf ~/.cache/JetBrains
> rm -f ~/.local/share/applications/jetbrains*.desktop
> rm -rf ~/Downloads/jetbrains-toolbox-*
> ```

### Setting Up in Toolbox

Then I moved everything into my toolbox (I call mine "sandbox"):

> [!Code] Shell
> ```bash
> # Entered my toolbox
> toolbox enter sandbox
>
> # Installed dependencies
> sudo dnf install -y fuse fuse-libs python3 python3-pip python3-virtualenv python3-devel git
>
> # Downloaded JetBrains Toolbox (as of writing, the latest version is 3.2.0.65851)
> cd ~/Downloads
> wget https://download.jetbrains.com/toolbox/jetbrains-toolbox-3.2.0.65851.tar.gz
> tar -xzf jetbrains-toolbox-*.tar.gz
> cd jetbrains-toolbox-*/bin
> ./jetbrains-toolbox
> ```

I installed PyCharm and Rust Rover through the Toolbox App and pinned them to my dock for easy access.

---

## The REAL Problem: Misconfigured Virtual Environment

But guess what? The problem persisted! Even running completely from within the toolbox, PyCharm still couldn't see my imports.

After some investigation, I discovered the actual issue:

**PyCharm's editor wasn't properly configured to use my venv.**

- When I *ran* scripts in the terminal: I could activate the venv and run scripts successfully
- In the *editor* (for linting, imports, analysis): PyCharm's interpreter setting wasn't pointing to the correct venv, or was pointing to a corrupted/outdated one

The venv was outdated and misconfigured - likely created with an older Python version or in a different environment (possibly on the host before moving to toolbox). This caused PyCharm's editor to fail at recognising the venv properly, even though I could still activate it manually in the terminal.

### Why This Happens on Silverblue

**Interestingly, I never encountered this issue when I was using Ubuntu.** This problem seems to be more common on immutable systems like Fedora Silverblue, likely because:

1. **Host/Toolbox environment switching**: On Silverblue, you often move between host and toolbox environments. If PyCharm was initially on the host and then moved to toolbox, old venv configurations and paths can become invalid.
2. **Path inconsistencies**: Venvs created before moving PyCharm to a toolbox may reference Python interpreters or paths that don't exist in the new environment.
3. **Development workflow differences**: On Ubuntu, you'd typically install everything directly on the system. On Silverblue, the recommended toolbox approach means more environment transitions where venv configurations can break.

On traditional Linux distributions like Ubuntu, you don't have this host/container separation, so PyCharm and your venvs stay in one consistent environment.

### The Solution

The fix was surprisingly simple. **All I had to do was delete the .venv directory in my project's root, and then create a fresh venv through PyCharm:**

> [!Code] Shell
> ```bash
> # Opened terminal and moved to the path of project
> cd ~/PyCharmMiscProjects
>
> # Delete the existing .venv directory
> rm -rf .venv
> ```

Then, in the bottom right of my PyCharm, I clicked on the interpreter name `Python 3.13 (PyCharmMiscProjects)`, then I proceeded to click on `Add New Interpreter` → `Add Local Interpreter`.

From here, a window popped up which is used to create a venv, and the values for each input should be as follows:

- **Environment**: `Generate new`
- **Type**: `Virtualenv`
- **Base Python**: `/usr/bin/python3.13`
- **Location**: `/var/home/rly0nheart/PyCharmMiscProjects/.venv`

And then I clicked the `Okay` button.

After that, I was able to install the missing packages and this is what I saw in the editor:

Imports were recognised, linting worked, Black formatter was available, and the 'full PyCharm experience' was back.

---

## What I Learned

1. **The toolbox approach is valuable** - Running PyCharm in a Fedora Toolbox gives you full access to Python tools, packages, and development dependencies without fighting with Silverblue's immutability. This is the recommended approach for development on immutable systems.

2. **But it wasn't the root cause** - My original problem would have occurred regardless of where PyCharm was running. The issue was PyCharm's editor not being properly configured to use the correct venv.

3. **Immutable systems need extra care** - Venv issues like this are more common on immutable systems like Silverblue than on traditional distributions like Ubuntu. When in doubt, recreate your venv.

4. **Check your interpreters** - When PyCharm behaves strangely (runs code fine but shows errors in the editor), always check that the editor and runtime are using the same Python interpreter. Use `Settings → Project → Python Interpreter` to verify this.

5. **Venv versioning matters** - If you created a venv with an older Python version and then updated Python, recreate the venv from scratch. Don't try to upgrade it in place, as this can lead to compatibility issues.

6. **Editor vs Runtime split** - PyCharm's terminal lets you manually activate any venv and run scripts, but the editor's code analysis uses PyCharm's configured interpreter setting. These must be in sync for everything to work properly.

---

## Quick Diagnostic Steps

If you're experiencing similar issues, here's how to diagnose:

> [!Code] Shell
> ```bash
> # In PyCharm's terminal, check what Python you're actually using
> which python
> python --version
> pip list
> ```

Then compare that with what's shown in **Settings → Project → Python Interpreter**. If they don't match, that's your problem.

Also, check **Run → Edit Configurations** to see what interpreter is used when running scripts. All three (terminal, editor, runtime) should point to the same Python executable.

---

## Final Setup

Now I have PyCharm running smoothly in my toolbox:
- Full linting and code analysis working
- Venvs functioning properly
- Black, pylint, mypy all integrated
- Pinned to my dock for easy access

If you're running Silverblue and developing with Python, I highly recommend the toolbox approach - just make sure your venvs are properly configured and up to date!

---

## In Conclusion

Sometimes the solution to a problem isn't what you initially think it is. I assumed Silverblue's immutability was the culprit and went through the process of moving everything into a toolbox (which is still a good practice). However, the real issue was much simpler: a misconfigured venv that needed to be recreated.

When debugging development environment issues on immutable systems like Silverblue, start with the simplest explanations first:
- Is your venv properly configured in PyCharm's settings?
- Is your venv in sync with your current Python version?
- Are all components (editor, runtime, terminal) using the same interpreter?

Only after ruling out these common issues should you look for more complex systemic problems. In my case, the toolbox migration was valuable for other reasons, but it wasn't the fix I needed - just deleting and recreating the venv through PyCharm's interface was.

**A final note for Ubuntu and other traditional Linux users**: If you're coming from a mutable distribution like Ubuntu, be aware that immutable systems like Silverblue can introduce these kinds of venv issues more frequently. Always recreate your venvs when moving projects between environments or after system updates.