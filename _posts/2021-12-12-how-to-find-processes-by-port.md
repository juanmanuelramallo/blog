---
layout: post
title: "How to find the PID of a process using a specific port"
categories: how-to
tags: [how-to, linux]
---

To find out what processes are using a specific port, use `lsof`.

```bash
lsof -i :PORT
```

<!--more-->

## Examples

List all processes using the 5432 port (commonly used by postgres)
```bash
➜ lsof -i :5432
COMMAND  PID   USER   FD   TYPE             DEVICE SIZE/OFF NODE NAME
postgres 777    1ma    7u  IPv6 0x0123456789abcdef 0t0  TCP localhost:postgresql (LISTEN)
postgres 777    1ma    8u  IPv4 0x1123456789abcdef 0t0  TCP localhost:postgresql (LISTEN)
```

List all processes using the 4000 port (this blog in development)
```bash
➜ lsof -i :4000
COMMAND   PID   USER   FD   TYPE             DEVICE SIZE/OFF NODE NAME
ruby    59182    1ma   10u  IPv4 0x2123456789abcdef      0t0  TCP localhost:terabase (LISTEN)
```

## Alternatives

`netstat` can be used with grep to look for the port, but not possible in macOS as `netstat` won't output the process ID.

`ps -ef` can be used with grep too, but we'll need some bash sorcery to keep the first line of the `ps` output (the headers line).
