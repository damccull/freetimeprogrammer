
+++
title = "Containerized FoundryVTT with Cloudflare Tunnels"
date = 2025-07-18T22:13:00Z

description = "Run your FoundryVTT as a Docker or podman container and access it via Cloudflare tunnels."

[taxonomies]
tags = ["FoundryVTT", "VTT", "Docker", "Podman", "Cloudflare Tunnels"]
categories = ["TTRPG", "Containers"]
+++

<!-- <note> -->
<!--   <ul> -->
<!--   </ul> -->
<!-- </note> -->

# What is this about?
Let's start with just a bit of background. Table Top Role Playing Games (TTRPG) like _[Dungeons
and Dragons][dnd-beyond]_ or the [Cosmere RPG][cosmere-rpg] are games traditionally played with
pen and paper with a group of people all in the same physical location. As the internet started
getting fast and more accessible, some fellow TTRPG nerds started making software to turn that
table top experience into a virtual experience. The games are played the same way, but they can
now be played over the internet across vast distances.

Several of these "Virtual Table Tops" (VTT) exist now, such as Roll20.com, an example of a
completely web-based experience, and locally run software like FantasyGrounds, which requires
all players to have an installed copy. Some others use 3d rendered graphics and are great for
specific games, but are not universal for any game system. You may be able to play D&D but not
Star Trek, for instance.

My favorite VTT currently, however, is [FoundryVTT][foundry-vtt], which is a web-based experience
like [Roll20][roll20] but is hosted locally by the owner. FoundryVTT offers:

- one-time purchase the software and perpetual use
- free upgrades to newer versions
- an incredibly powerful mod API
- community-driven development of game systems and plugins (modules)
- a fully playable reference D&D5e system supporting 5e classic and the new 2024 rules
- a massive repository of pre-built game systems
- a massive repository of pre-built modules to extend the functionality of FoundryVTT and the
game systems
- the ability to install systems and modules that are not distributed via FoundryVTT's official
shop
- so much more; go see their [website][foundry-vtt]

# Other Options for Using FoundryVTT
FoundryVTT is written in node and run, by default, as a local program running in the electron
wrapper, and it can perform UPNP negotiation with your router to open external ports and allow
your players to connect. This gives users a very simple way to get started.

However, many people eventually get to a point where they want to run the VTT as a server and
have it be online all the time. For people who just want someone else to do the work for this,
there are [several hosting companies][foundry-vtt-partners] available that can handle the
back-end work for you, but you will have to pay for it, and you may not have full access to all
customizations you want to use.

# Self-hosting - the Reason You Read This Far
Ok, now that all the introductory junk is out of the way, let's get started with why you're
really still reading: self-hosting your FoundryVTT instance in either Docker or podman and
ensuring public internet access.

The prerequisites are fairly simple:
- have your choice of linux running with Docker or podman installed
on a computer connected to the internet.
- have a domain name with dns handled by Cloudflare

I will leave it to you to get this far.

# Cloudflare Tunnels Setup
## What's a Tunnel?
Let's first start by understanding the tunnel. Tunnels, in networking, are simply a way to wrap
one packet inside of another, generally to let the inner packet traverse a network border, or
be routed to a network that is not publicly routeable (like your 192.168.1.1 home network).
This is accomplished by taking a packet that can't normally pass through a firewall or router,
and putting it into the payload slot of another packet that can pass. Regular tunnels are
generally configured such that client trying to connect to a service will also initiate the
tunnel.

Cloudflare uses a reverse tunnel method along with a proxy server where a program on the inside
of a protected network initiates a tunnel connect outward toward the proxy. The proxy accepts
the connection and, because it is a two-way tunnel, is now able to route traffic from the
internet through the tunnel. Connections from clients first go to Cloudflare, and Clouflare's
proxy guides the packets through the tunnel to your computer, where the connection is made to
whatever service you've specified in the configuration. Replies are sent back up the tunnel and
Cloudflare forwards them on to the original client.

See a bunch of youtube videos for a more in-depth understanding.

## Make the Tunnel
Now let's get the Cloudflare side of the tunnel set up. To use this option, you will need to
own a domain name and have Cloudflare.com be the DNS authority for your domain, as stated in
the prerequisites. Once that is done, however, you set up the tunnel configuration and grab
the Docker configuration.

1. Log into cloudflare so you see the "Account Home" dashboard, without having clicked into a
   domain name.
2. On the left look for "Zero Trust" and click that.
3. On the left menu, again, look for "Networks" and expand it, then click Tunnels.
4. Create a tunnel, and choose Cloudflared as the type, then give it a name. I recommend
   'foundryvtt' or similar.
5. Choose your "operating environment" to be Docker, and copy the entire "docker run" command
   you see. Paste it somewhere for later because we're going to need the key you see in there.
   Then click Next.
6. Fill in the information needed to create the tunnel on Cloudflare's end:
    - Subdomain: `fvtt` or your choice
    - Domain: select your domain name
    - Path: leave it empty
    - Service Type: `http`
    - Service URL: `foundryvtt:30000`
7. Save the tunnel and ensure you save the Docker command from earlier. You can get back to
   that commmand by editing this tunnel you've just created if you lose it.
8. On the left menu, click the left "back" arrow to leave zero trust and go back to the
   dashboard.
9. Open the base domain name you chose to use, then choose the Network on the left menu. In
   the settings panel that opens, enable the WebSockets option.
10. On the left menu, click Rules to expand, then choose Overview, then "Create rule" button,
    and create a Configuration Rule.
11. Name your new rule "foundryvtt no rockerloader" and fill out the options as follows:
    - Field: `Hostname`
    - Operator: `equals`
    - Value: `fvtt.yourdomain.com` or whatever address you chose
    - Rocket Loader: Click add, and leave it unchecked
12. Deploy the rule. This solves an issue that breaks the FoundryVTT UI.

# Container Setup
Now that we have a tunnel configured on Cloudflare, we need to get our containers set up. I am
going to split up the podman and Docker options into separate sections because, while they are
very similar, there are a couple slight differences due to how Docker runs as root and podman
does not. In both cases, however, we're going to use a compose.yml file to specify a set of
services that all need to run as one to offer FoundryVTT over the internet. Our specific set of
services are:

1. FoundryVTT's node version running in a specific container build by a person called felddy
2. The cloudflared binary running in a container provided by Cloudflare

These two services will have network access to each other and to the internet, but not to the
host computer they are running on. We will also need to set up a local storage location that
will be mounted into the FoundryVTT container so that your worlds will not disappear each time
you restart the container.

While I have been using Docker for years, I have recently started to use podman for better
security, since it runs as a user and not as root.

## Common Setup for Both Podman and Docker

Create a folder path for storing your containers and their data. Here I only create one
for foundryvtt but I put it under 'containers' because I can add additional pods or individual
containers to this folder later and keep my home folder clean. The 'fvtt-home' folder is where
FoundryVTT software will store all its data.

```bash
mkdir -p ~/containers/foundryvtt

mkdir -p ~/containers/foundryvtt/fvtt-home
```

Create a file to hold the tunnel key we got earlier from Cloudflare. You only need the token
portion of the command. Paste it after the token variable.

File name: `/home/<user>/containers/foundryvtt/tunnel.env`
```env
TUNNEL_TOKEN=fgGkM...
```

Create a file to store your secrets. This will need to be ignored by git if you choose to keep
this configuration in a git repo. This file is used by felddy's container to automatically
download the node version of FoundryVTT and set the admin password for your server. Replace
each value with your own information.

File name: `/home/<user>/containers/foundryvtt/secrets.json`
```json
{
    "foundry_admin_key": "<desired admin panel password>",
    "foundry_password": "<foundryvtt.com password>",
    "foundry_username": "<foundryvtt.com username>"
}
```

Create a compose configuration file to define the services and configure the pod. In the
following compose file there are some changes you need to make:

1. Change the 'volumes' path to match your user name.
2. Type 'id' on your command line and set the "user" line to your user id and group id. This is
   the line that says `user: 1000:100`. The first number is the user id and the second is the
   group id.
3. This example uses FoundryVTT version 12.343 even though it use's felddy's version 13
   container. If you want version 13 of the FoundryVTT server, delete the `FOUNDRY_VERSION`
   environment variable.

File name: `/home/<user>/containers/foundryvtt/compose.yml`
```yml
services:
  foundryvtt:
    image: felddy/foundryvtt:13
    user: 1000:100
    stop_grace_period: 5m
    restart: always
    deploy:
      replicas: 1
    volumes:
      - /home/<user>/containers/foundryvtt/fvtt-home:/data
    secrets:
      - source: fvtt_secrets
        target: config.json
    environment:
      - CONTAINER_CACHE=/data/download_cache
      - CONTAINER_PRESERVE_CONFIG=true
      - FOUNDRY_VERSION=12.343
      - FOUNDRY_HOME=.

  tunnel:
    image: cloudflare/cloudflared:latest
    command: tunnel --no-autoupdate run
    restart: always
    env_file: tunnel.env
    depends_on:
      - foundryvtt

secrets:
  fvtt_secrets:
    file: secrets.json
```

## Podman
Podman will require us to manually create a user-level systemd service. If you are using
another init system for your linux server, you will need to figure out how to do this on your
own, but I will demonstrate the systemd version.

Let's ensure the prerequisites are met:
1. Install podman
2. Install podman-compose
3. Ensure podman has search registries setup

### Search Registries
Docker defaults to docker.io for its registry but podman doesn't always default to a particular
registry. Let's tell it to use docker.io, then quay.io by default.

File name: `/home/<user>/.config/containers/registries.conf`
```toml
# An array of host[:port] registries to try if the image name is not fully qualified
unqualified-search-registries = ["docker.io", "quay.io"]
```

### Pod Configuration
Create a new file in your linux server under the user you want to run the FoundryVTT server
and paste the following configuration ensuring that you change the username in the working folder
variable.

File name: `/home/<username>/.config/systemd/user/podman-compose@foundryvtt.service`
```ini
[Install]
WantedBy=default.target

[Service]
Environment=COMPOSE_PROJECT_NAME=foundryvtt
Environment=XDG_RUNTIME_DIR=/run/user/1000
ExecStart=podman-compose wait
# ExecStartPre=launch-fvtt.sh
ExecStartPre=podman-compose --pod-args "--userns keep-id" --in-pod pod_foundryvtt up --no-start
ExecStartPre=podman pod start pod_foundryvtt
ExecStop=podman pod stop pod_foundryvtt
ExecStop=podman-compose down
WorkingDirectory=/home/<user>/containers/foundryvtt

[Unit]
After=network-online.target
Description=FoundryVTT service
```

TODO: REMOVE THIS SCRIPT IF POSSIBLE BASED ON ABOVE
Create this start script which will be used by the systemd service and make it executable with
`chmod +x launch-fvtt.sh`

File name: `/home/<user>/containers/foundryvtt/launch-fvtt.sh`
```bash
#!/usr/bin/env bash
podman-compose --pod-args "--userns keep-id" --in-pod pod_foundryvtt up --no-start
podman pod start pod_foundryvtt
```


Now we need to test the podman compose setup, ensure it creates its data in the right place and
is able to download and start the server. When you run this, you will be prompted for which
registry to pull the image from if you do not already have these images locally.

```bash
cd ~/containers/foundryvtt
podman-compose --pod-args "--userns keep-id" --in-pod pod_foundryvtt up --no-start
podman pod start pod_foundryvtt
```

Check that the 'fvtt-home' folder is no longer empty and that the owner and group of the files
inside are the same as the user you are logged in as. If you see numbers instead of your
username and the name of the group you belong to (which might be 'users' or it might also be
your username), it just means that podman is using virtual IDs inside the container. It should
not be an issue if it is, but it also shouldn't be doing that due to the way we create the pod
in the systemd service.

```bash
ls -al fvtt-home

<user>@server ~/containers/foundryvtt> ls -al fvtt-home/
total 0
drwxrwxr-x 1 <user> users  70 Jul 18 14:00 .
drwxr-xr-x 1 <user> users 154 Jul 18 13:43 ..
drwxrwxr-x 1 <user> users  64 Jul  2 12:09 Backups
drwxrwxr-x 1 <user> users 188 Jul 14 16:43 Config
drwxrwxr-x 1 <user> users 120 Nov 21  2023 Data
drwxrwxr-x 1 <user> users  66 Jul 18 14:01 download_cache
drwxrwxr-x 1 <user> users 694 Jul 17 14:07 Logs
```

You can check the logs for the FoundryVTT container as well.

```bash
# for the whole pod
podman pod logs pod_foundryvtt

# or, for a single container, but you will have to ensure the container name matches
podman logs foundryvtt_foundryvtt_1
```

Next, stop and remove the pod to avoid conflicts later.

```bash
# First, turn off the pod to prevent conflicts
cd ~/containers/foundryvtt
podman pod stop pod_foundryvtt
podman pod rm pod_foundryvtt
```

If everything is working correctly and you can connect to https://fvtt.yourdomain.com in your
browser and get the FoundryVTT interface, then we can just enable the service and it should
auto-start with your server from now on.

```bash
# Next, enable the service
systemctl --user enable --now podman-compose@foundryvtt.service

# Check if it started automatically
systemctl --user status podman-compose@foundryvtt.service

# If not, you can manually start it
systemctl --user start podman-compose@foundryvtt.service
```

Try again to visit the web page and see if everything is online.

## Docker

Let's ensure the prerequisites are met:
1. Install docker
2. Ensure your user is part of the 'docker' linux group and log all the way out, then back in

Now we need to test the docker compose setup, ensure it creates its data in the right place and
is able to download and start the server.

```bash
cd ~/containers/foundryvtt
docker compose up -d
```

Check that the 'fvtt-home' folder is no longer empty and that the owner and group of the files
inside are the same as the user you are logged in as. If you see numbers instead of your
username and the name of the group you belong to (which might be 'users' or it might also be
your username), it just means that podman is using virtual IDs inside the container. It should
not be an issue if it is, but it also shouldn't be doing that due to the way we create the pod
in the systemd service.

```bash
ls -al fvtt-home

<user>@server ~/containers/foundryvtt> ls -al fvtt-home/
total 0
drwxrwxr-x 1 <user> users  70 Jul 18 14:00 .
drwxr-xr-x 1 <user> users 154 Jul 18 13:43 ..
drwxrwxr-x 1 <user> users  64 Jul  2 12:09 Backups
drwxrwxr-x 1 <user> users 188 Jul 14 16:43 Config
drwxrwxr-x 1 <user> users 120 Nov 21  2023 Data
drwxrwxr-x 1 <user> users  66 Jul 18 14:01 download_cache
drwxrwxr-x 1 <user> users 694 Jul 17 14:07 Logs
```

You can check the logs for the FoundryVTT container as well.

```bash
# or, for a single container in the pair
docker compose logs foundryvtt
```

If everything is working correctly and you can connect to https://fvtt.yourdomain.com in your
browser and get the FoundryVTT interface, then you are done. The containers should auto-start
when the Docker engine starts and auto-restart if they crash.

If you want to turn the service off, type this:
```bash
# First, turn off the pod to prevent conflicts
cd ~/containers/foundryvtt
docker compose down
```

# The Ending
The overall process to get a containerized FoundryVTT service running isn't too difficult. It
does require some basic understanding of the linux, Docker/Podman, and how services and
containers work, but it's something anyone can do with a bit of research. From here, I would
encourage you to get to know docker or podman better, play around with the command line a lot
more, and do some research on tunnels and reverse tunnels.

Good luck!

[foundry-vtt]: https://foundryvtt.com
[foundry-vtt-partners]: https://foundryvtt.com/article/partnerships/
[cosmere-rpg]: https://www.brotherwisegames.com/cosmere-rpg
[roll20]: https://roll20.com
[dnd-beyond]: https://dndbeyond.com
