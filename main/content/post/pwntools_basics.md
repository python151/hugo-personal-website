+++
author = "Emily Miller"
title = "Crash course pwntools"
date = "2025-08-31"
description = """pwntools is an amazing collection of tools which streamline the exploit development process, designed especially for CTF pwn challenges.""""
categories = [ "tooling-guides" ]
+++

## What's a pwntools?

`pwntools` is a python package used predominantly in the CTF space for pwn challenges. It has a variety of utilities, both in the command line (checksec, asm, etc.) and in python itself.

To install, you'll typically run something like `sudo apt install python3-pwntools` or `pip install pwntools`, though this varies by package manager. In general, you'll install it however you install other python packages.

## What utilities does this give me?

The main way to see `pwntools` command line utilities is by running `pwn [utility_name] [arguments]`, for instance `pwn checksec ./mybinary` will check the protections of the binary called `mybinary`. These are documented in more depth [here](https://docs.pwntools.com/en/stable/commandline.html).

## How do I write exploits with it?

To start, you'll need to import the package. This is typically done with `from pwn import *` for simplicity.

**Connecting to challenges**

Then, you'll need to actually connect to the challenge. The two main ways of doing so are by launching the program locally `p = process('./mybinary')` and connecting to a remote server `p = remote('123.123.123.123', 1234)`. There are other tools exposed in pwntools to do this! For instance, you can launch the program with a gdb session or start through an ssh connection. 

**Interacting with challenges**

To interact with the connection, you can use methods on the connection object. For instance `p.send(payload)` or `p.sendline(payload)`. To recieve data, you can use methods like `p.recv()`, `p.recvuntil(b'example_prompt>')`, or `p.recvall()`. Each of these returns raw bytes which you can then handle in python natively. 

**Packing and unpacking data**

In binary exploitation, you're often in a situation where you need to pack and unpack pointers. Luckily, pwntools has made this easy! To pack, you can use p8, p16, p32, p64, etc. to pack pointers into bytes object (which will default to your systems endianness, usually little). To unpack, you can use u8, u16, u32, u64, though this does require the number of bytes be exactly the number given (for instance, 8 bytes for a u64 call). Some like using python's native `struct` library for parsing, which allows you to do some more advanced specification of a struct to extract data. As a quick tip, if you have data like "0x1234" (like you'd get from a format string leak), you can use `int(string_to_decode, 0)`, which will automatically detect the `0x` and parse the integer.

**Setting context**

One important thing in pwntools is being able to customize the context for many of the actions. For instance, changing the architecture or how it will launch terminals. You can do this with the `context` object! For instance, to set the architecture, you can do something like `context.arch = "amd64"` and to set the terminal you can do `context.terminal = "tmux-split -h"` (this will actually have pwntools split any windows it opens --- like debuggers, in a new tmux pane!).

**Shellcoding and assembling code**

When you need to assemble code (for instance, for shellcoding challenges), you can use the `asm` function, which will assemble raw assembly into bytes by default. Additionally, pwntools has utilities to aid shellcode generation in the `shellcraft` subsystem. For instance, prewritten shellcode with `shellcode.sh()`, but you can similarly have `shellcode.cat("flag.txt")`, which will attempt to cat the `flag.txt`. Importantly, many of these are architecture dependent features, but x86-64 by far has the best support, as that's what's most widely used.

