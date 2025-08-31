+++
author = "Emily Miller"
title = "Crash course GDB"
date = "2025-02-11"
description = """The use of debuggers like GDB is a fundamental skill in binary
exploitation and reverse engineering, but can be difficult to grasp at first.
Here's a 'Crash course' GDB.""""
categories = [ "tooling-guides" ]
+++

The use of debuggers like GDB is a fundamental skill in binary
exploitation and reverse engineering, but can be difficult to grasp at first.
Here's a "Crash course" GDB.

#### What is GDB?

GDB stands for the GNU Debugger, so put simply, it's a FOSS (Free and Open
Source Software) debugging tool. At its most basic level, it allows you to run a
program, set breakpoints, and be able to look "inside" the program at each of
those breakpoints, including raw memory (looking at the stack, heap, current
instructions, etc.) and register values (for instance the instruction pointer or
stack pointer).

Base GDB is old, but a lot of development has gone into wrappers around GDB
including `gef` and `pwngdb`. We will not be looking too much into those in this
tutorial, and in fact I'd recommend avoiding them until you have the basics of
GDB down, but I'd recommend reading up on those as you get into more advanced
exploitation (especially for heap exploitation, a tool like `gef` allows you to
inspect bins and see heap allocations much easier).

#### Enough waffling! How do I use it?

Starting from installation, while this is system specific, it can be installed
with the vast majority of package managers natively. Note: I'd *highly*
recommend you use Linux when working with CTFs in general, but especially binary
exploitation, because the vast majority of binaries in CTFs are Linux based.

Now, let's see an example workflow.

```bash
# Open the binary in gdb
emily747@nix-framework /path/to/your % gdb ./binary
# Disassemble the main function
(gdb) disas main
Dump of assembler code for function main:
   0x0000000000401156 <+0>:	    endbr64
   0x000000000040115a <+4>:	    push   rbp
   0x000000000040115b <+5>:	    mov    rbp,rsp
   0x000000000040115e <+8>:	    mov    eax,0x0
   0x0000000000401163 <+13>:	call   0x401136 <vuln>
   0x0000000000401168 <+18>:	mov    eax,0x0
   0x000000000040116d <+23>:	pop    rbp
   0x000000000040116e <+24>:	ret
# Break when the instruction pointer is 13 bytes past main
# That is, break at a 13 byte offset to main
(gdb) break *main+13
Breakpoint 1 at 0x401163
# Run the program
(gdb) run
# The program will then pause at the breakpoint
# Print out the first 800 bytes on the stack in 8 byte chunks
(gdb) x/100gx $sp
# Next we can step over the function call, such that it will
# continue until main+18 automatically
(gdb) step
# And to continue the program's normal flow after that
(gdb) c
```

It's important to remember that GDB is just a tool, not a magic bullet, and it
tends to be a tool that doesn't hold your hand a lot. Just like any tool, it can
only be really be learned with practice.
