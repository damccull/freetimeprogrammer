+++
title = "Managing NixOS Generations"
date = 2024-06-25T15:05:00Z
update = 2024-06-25T15:05:00Z
draft = true

description = "NixOS likes to spam your boot menu and keep unused things on your hard drive. Fix that easily!"

[taxonomies]
tags = ["NixOS", "bash", "scripting"]
categories = ["Lessons", "Operating Systems"]
+++

NixOS has a silly little problem for new users. It likes to fill up your disk space with older, unused software or versions of software. It's not doing this maliciously, mind you. In fact, it's trying very hard to help you out by ensuring you will always have a bootable system if you screw something up. Those older versions and software somewhat akin to Microsoft Windows' "last known good configuration", except way better. However, they do take up more and more disk space if you don't clear them out now and again. That's not the worst of it, though, not by a long shot.

The worst part is that it floods your boot menu, be it grub2 or systemd-boot, with countless entries! Well, ok, not _countless_ entries. They are numbered, after all. However, after a while it becomes a giant, overwhelming, wall of text. If you have the disk space, and would like to maintain a full history of every single version of your operating system you've created from the beginning of time, _and_ you aren't bothered by that magnificent palisade of boot entries, please stop here and read no further. Good day to you.

If you are at all interested in reducing that ridiculous clutter to a manageable amount while simultaneously saving valuable disk space, please read on. This article will undoubtedly become your go-to source to create a blissful, well-pruned list of your most recent configurations.
