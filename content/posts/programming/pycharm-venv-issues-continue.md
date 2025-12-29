---
author: Ritchie
date: 2025-12-24T10:00:00+02:00
title: PyCharm Venv Issues Continue
subtitle: Global Venv Interference
categories:
  - programming
tags:
  - python
  - pycharm
---

About 3 days ago, I published a post about [**Fixing PyCharm's Missing Imports and Linting on Fedora Silverblue**](http://localhost:1313/posts/programming/fixing-pycharms-missing-imports-and-linting-on-fedora-silverblue/), but a day later, I ran into yet another venv-related issue.

## The Problem

I was experiencing a strange issue where:
- **Everything seemed to be working**. I could install packages, linting was functional, and scripts ran fine
- **But Black formatter refused to work**. It would fail with an error when trying to format code
- PyCharm showed the interpreter name in the bottom right, but **clicking it showed nothing**, as if no interpreter was configured
- In the interpreter settings, my project's venv was marked as **`[invalid]`**, but PyCharm was actually using a different venv from my home directory instead
- PyCharm insisted on using Python 3.14 from the host system, even though my toolbox only had Python 3.13
- Creating new project venvs didn't help. PyCharm kept ignoring them in favour of the global one

The frustrating part was that things *appeared* to work because PyCharm was silently falling back to the wrong venv, making it hard to pinpoint what was actually wrong.

## The Root Cause

After some back and forths with Claude, I realised I had a **global venv in my home directory** (`~/.venv`) that I had created back in July (again, *"ifishikumana fiiwa"*). This global venv was interfering with my project-specific venvs.

When PyCharm (and the new `uv` package manager) looked for a venv, they were finding the global one first instead of my project's venv. This caused all sorts of confusion:

```bash
# uv was using the global venv instead of the project one
uv pip list

Using Python 3.14.2 environment at: /var/home/rly0nheart/.venv
```

But here's where it gets interesting. When I checked the global venv:

```bash
~/.venv/bin/python --version

Python 3.13.11
```

Wait, what? The venv says 3.13.11, but `uv` detected 3.14.2?

**Here's what actually happened:**

When I created `~/.venv` in July, my host system had Python 3.13. The venv's Python was a symlink to `/usr/bin/python`:

```bash
# 'ce' command is from cerium, my ls-like command-line utility (currently private). 
# Replacing 'ce' with 'ls' should work all the same.

ce -la ~/.venv/bin/python

lrwxrwxrwx@ 15 rly0nheart Jul 28 19:15 python -> /usr/bin/python
```

Between July and now, I received a number of system updates, which also upgraded Python to 3.14 (the latest, as of writing). Since the venv's Python was symlinked to the system Python, the venv's version "changed" without me touching it:

```bash
# On the host system
/usr/bin/python --version

Python 3.14.2
```

So the timeline was:
1. **July**: Created `~/.venv` → pointed to `/usr/bin/python` (which was Python 3.13 at the time)
2. **Later**: Host system received updates and upgraded to Python 3.14
3. **Now**: `~/.venv/bin/python` → `/usr/bin/python` → Python 3.14.2 on the host
4. **My toolbox**: Still running Python 3.13

This created a version mismatch nightmare where:
- PyCharm (running in toolbox with Python 3.13) was trying to use a venv that pointed to Python 3.14 on the host
- The venv appeared to be crossing the toolbox boundary, or at least confusing PyCharm about which Python to use
- Black and other tools couldn't work properly because of the version mismatch

---

## The Solution

The fix was simple, remove or rename the global venv:

```bash
# Remove the global venv from your home directory
mv ~/.venv ~/.venv.backup

# Or delete it entirely if you don't need it
rm -rf ~/.venv
```

After removing the global venv:
1. PyCharm could finally detect project venvs properly
2. The interpreter showed up correctly in the settings
3. Black formatter started working
4. Everything worked as expected

## Lessons Learned

1. **Don't create global venvs in your home directory (`~/.venv`)**: They'll probably interfere with project-specific venvs and confuse tools like PyCharm and uv. Always create venvs inside your project directories (like `~/project/.venv`).

2. **Venvs can "change versions" when system Python upgrades**: If your venv's Python is symlinked to the system Python (like `/usr/bin/python`), and the system upgrades Python, your venv will suddenly point to a different Python version without you realising it. This is especially problematic on systems where the host and containers (like Fedora Toolbox) have different Python versions.

3. **On immutable systems like Silverblue, venv path resolution can be tricky**: A venv in your home directory can reference the host system Python, which may cause issues when working in a toolbox with a different Python version. The exact mechanism of how this causes problems isn't entirely clear to me, but removing the global venv resolved all my issues.

## In Conclusion
If you're experiencing strange venv issues:
1. Check for global venvs in your home directory: `find ~ -name ".venv" -type d`
2. Check what Python your venv is actually using: `readlink -f .venv/bin/python`
3. Consider switching back to `pip` in PyCharm:
   - Settings → Tools → Python Integrated Tools
   - Package installer: Change from "uv" to "pip"

This might be a recurring issue when working with containerised environments like Fedora Toolbox, venv path and version management requires extra attention. The combination of host/toolbox separation and venv symlinks to system Python can create opportunities for confusion. Always double-check your venv configurations and where they're actually pointing!