---
layout: post
title:  "Use error objects instead of strings"
categories: why-not
tags: [why-not, ruby]
excerpt: "[...] we tend to write a lovely: raise 'some error explanation'"
---

Every once in a while we need to raise an error so that our program exits and displays the error in the standard error.
And most of the time (seen it several times while code reviewing) we tend to write a lovely: `raise "some error explanation"`

## Why not use an object instead of a string?

When we raise errors using objects we'll be able to easily identify those errors, everywhere (logs, console, when rescuing).
Take a look at this example:
```
[1] pry(main)> raise "some error"
RuntimeError: some error
```
It raised a RuntimeError which is an error that can occur not only here.

```
[2] pry(main)> class ThisErrorIKnow < StandardError; end;
[3] pry(main)> raise ThisErrorIKnow, "some error explanation"
ThisErrorIKnow: some error explanation
```
Here it raised our custom error class which in my opinion is better because we'll be able to rescue this error specifically later if needed.


