
+++
title = "Containerized FoundryVTT with Cloudflare Tunnels"
date = 2025-07-18T22:13:00Z
draft = true

description = "Run your FoundryVTT as a Docker or podman container and access it via Cloudflare tunnels."

[taxonomies]
tags = ["FoundryVTT", "VTT", "Containers", "Docker", "Podman", "Cloudflare Tunnels"]
categories = ["TTRPG"]
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

## Podman

## Docker




[foundry-vtt]: https://foundryvtt.com
[foundry-vtt-partners]: https://foundryvtt.com/article/partnerships/
[cosmere-rpg]: https://www.brotherwisegames.com/cosmere-rpg
[roll20]: https://roll20.com
[dnd-beyond]: https://dndbeyond.com
