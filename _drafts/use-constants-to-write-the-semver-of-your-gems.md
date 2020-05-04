---
layout: post
title:  "Use constants to specify the version of your gem"
categories: why-not
tags: [ruby, gems]
---

When developing gems or external libraries we frequently use semantic versioning as a string.
<!--more-->

```ruby
module MyGem
  VERSION = '1.4.0'
end
```

And when releasing a new version, git diff will show us this line was modified.

## Why not use a constant for each semver element instead?

Rewriting the previous version like this:

```ruby
module MyGem
  MAJOR = 1
  MINOR = 4
  PATCH = 0
  VERSION = [MAJOR, MINOR, PATCH].join('.')
end
```

It will allow us to keep our git diff clean when releasing, and also make our version string less prone to typos.


