+++
author = "Emily Miller"
title = "RSA Cheatsheet"
date = "2025-06-05"
description = "Basic overview of the RSA cryptosystem and some of its attacks."
tags = [  ]
+++


Links:
- https://github.com/mohamm4c/Attacks-On-RSA-using-Python/blob/main/Different_Attacks_on_RSA_system-Final.pdf
- https://www.ams.org/notices/199902/boneh.pdf
- https://eprint.iacr.org/2012/064.pdf

Cryptosystem:
- Pick some e (usually `0x10001`), and large N. These are made public. Now, pick some d, s.t. for any given m, $(m^e)^d=m \mod N$.  Also, we call the ciphertext $ct=m^e \mod N$
- In practice we usually keep e constant, and pick two primes $p,q$, and saying
$N=p\*q$, then we can use Euler's theorem and some properties of Euler's totient
function ($\phi(n)$), to show that $\phi(N)=(p-1)\*(q-1)$, and hence $d = e^{-1} \mod \phi(N)$, which is trivial to calculate.
	- From this, you can note that if you're able to factor N, then you'll get both primes and you can trivially calculate $d$. In this way, modern RSA is protected by the difficulty of factorization
- Also, in the real world, you should always use a padding scheme to protect against chosen plaintext attacks, the fact that it's deterministic and homomorphic, *but*, this isn't always (or in fact, usually) done in CTFs and RSA *can* still be secure without one, albeit conditionally on the stars aligning (and unlike AES, you don't *have* to have a padding scheme for it to work)

Some common vulnerabilities:
- Bad e:
	- If e=1, then d=1 (so ct = m)
	- If e=3 (or a similarly very low number), and N is very high, there's a decent chance you can just put `ct^(1/e)`  in sage to get m
- Bad d:
	- If $d < \frac{1}{3}N^\frac{1}{4}$, you can recover d with the Wiener
    Attack.
- Bad N / prime choices:
	- This is probably one of the most common, but remember that the security of it relies on the difficulty of calculating $\phi(N)$, so anything I'd say 1024 bits or lower total is in the danger zone of crackable
		- If you're ever unsure, just throw it into factordb.com and run `factor(N)` in sage.
	- Also, you'll sometimes see some weird setups where they choose only one
    prime and use that for N (so $\phi(N)=N-1$), or they'll choose only one
    prime and use its square for N (so $\phi(N)=\phi(p^2)=p(p-1)$), or similar
		- If you ever see a weird way of calculating your N, write it out to see if there may be a shortcut to calculate $\phi(N)$.
	- If $p$ and $q$ are very close, then you can use
		- https://en.wikipedia.org/wiki/Fermat%27s_factorization_method
	- If one of your primes is of the form $4p-1 = Ds^2$.  Here, D should be a small, square-free integer (an integer not divisible by any perfect square other than 1), and s is an integer. If this is the case, you can use Cheng's 4p-1 factorization algorithm.
		- It's niche, but it's a hell of an RSA backdoor
- Situational / many variable weirdness:
	- If you have multiple N with overlapping primes
		- For instance, $N_1=p\*q_1, N_2=p\*q_2$, then $p=\gcd(N_1, N_2)$, which breaks both almost instantly
		- This is actually way more real world than you may think, because it's significantly quicker to check hundreds or even thousands of public keys you find on the internet against each other, in the hopes that two of them happen to have collided, which instantly breaks both keys, see [here](https://eprint.iacr.org/2012/064.pdf)
	- Shared Modulus Attack
		- If you have the same $m$ and $N$, but different $e_1$, $e_2$, etc. then you can use extended euclidean to recover $N$
	- Håstad’s Broadcast Attack
		- Same m, small e, multiple different N
		- Use Chinese Remainder Theorem + e-th root to recover m
	- Same N, with known $e_0,d_0$ key pair and $e_1$.
		- So, we're sharing N, and with that N we have some valid $e$ and $d$, but need to decrypt a different $e$ with the same N.
		- There's an algorithm to factor N efficiently, it doesn't always work,
          but it does often.
