+++
author = "Emily Miller"
title = "How to host a CTF"
date = "2025-08-17"
description = "A crash course in CTF infrastructure"
tags = [  ]
+++

# Part 0: Infrastructure

In order to run this, you'll need some sort of server (a VM in Azure, AWS, Google Cloud, or a VPS will do just fine for this purpose), and you'll likely want a domain name. If you've never worked with servers or DNS before, I'd recommend reading a bit about [DNS](https://www.redhat.com/en/blog/dns-domain-name-servers) and and follow a [guide to setup a basic website](https://krystal.io/blog/post/beginner-s-guide-to-setting-up-a-vps-virtual-private-server).

# Part 1: Getting your platform up

Generally, in the year of our lord 2025, it's relatively easy to get a decent self hosted CTF platform up and running. For most people that's CTFd or rCTF. We'll focus on CTFd, because that's by far the most popular and very easy to get a basic set of containers running. 

To start, go to the [github repo](https://github.com/CTFd/CTFd) and clone the most recent stable version. I'd recommend cloning this into a directory with a name of the CTF you're running, because docker-compose will automatically namespace all containers by name of their containing directory (so if you always keep CTFd, they will all get namespaced together). That is:

```bash
mkdir my_ctf
git clone https://github.com/CTFd/CTFd.git my_ctf
```

This next step is optional, but is very useful to know how to do. You'll want to use your editor of choice to change the `docker-compose.yml` file to change the port bindings. The file will look something like the following:

```yaml
services:
  ctfd:
    build: .
    user: root
    restart: always
    ports:
      - "1337:8000" # change this line right here
    environment:
      - UPLOAD_FOLDER=/var/uploads
      - DATABASE_URL=mysql+pymysql://ctfd:ctfd@db/ctfd
      - REDIS_URL=redis://cache:6379
      - WORKERS=1
      - LOG_FOLDER=/var/log/CTFd
      - ACCESS_LOG=-
# file continues....
```
In this case, I've changed the port from 8000 to 1337 (by default the line looks like `"8000:8000"`) 

Next, you'll need to go ahead and build and run the containers, this is simple enough.

```bash
cd my_ctf
sudo docker compose build
sudo docker compose up -d
```

Now, your CTFd instance should be available at the port entered. You can test this by running `curl localhost:1337` (or whatever port you're binding to). By default this will run as HTTP only. It's 2025, TLSv3 is the standard, so how do we get that glorius lock icon? There are many ways of doing this, and if you already are using a reverse proxy like caddy, nginx, or something similar, you may already have a solution to this. If you don't have one already, I'd recommend caddy. It's very simple to use and will do most of the work for you.

To setup caddy for this, you'll want to go into a new directory, and create 2 files: another `docker-compose.yml` and a `Caddyfile`.

Put the following in your docker-compose.yml:
```yaml
version: '3'
services:
  caddy:
    container_name: caddy
    image: caddy
    restart: always
    ports:
      - '80:80'
      - '443:443'
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
```

Then the following in your Caddyfile:
```caddy
# Note: You'll need to change this to your actual domain name
my_ctf.example.com {
	# Note: You may need to change this port to whatever port you setup your CTFd instance to
	reverse_proxy localhost:1337
}
```

Now you can bring the container up, and it should automatically grab a certificate and handle proxying for you!

```bash
sudo docker compose up -d
```

# Part 2: Challenge hosting

This section is a work in progress, but I'd recommend looking into [redjail](https://github.com/redpwn/jail)for most pwn challenges
