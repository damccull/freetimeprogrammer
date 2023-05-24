+++
title = "Host a Blog for Free with Zola and GitHub Pages"
date = 2023-05-24T03:39:00Z
description = "Free website hosting with an awesome static site generator."

draft = true

[taxonomies]
tags = ["rust", "website", "zola"]
categories = ["Lessons"]

[extra]
ToC = true
+++

## Introduction

At some point in time, everyone wants to start a blog. During this time, people either spend hours agonizing over the best platform to host it, how much they're willing to pay, and which engine should run the blog; or they just grab the first free blog host that pops up in their Google search.

Both of these approaches will work, but with the first option, you will end up paying a monthly fee for a blog that's, honestly, unlikely to really take off. The second approach will leave you with ads stuck all over your blog, a set of templates that may or may not be customizable, and someone else's domain name attached to your blog.

There is a third, probably better way, my friends: Github pages, a static site generator, and, optionally, your own domain name. All for a grand total of $0. _(Unless you choose to use the optional custom domain name. Then you'll pay for that.)_

Both of the other options had downsides, and this one is no different. You need to learn a little git, and advanced formatting can drag you into the world of HTML and CSS. However, it also has several upsides: fully customizable templates, unlimited design flexibility, and the ease of using Markdown to write your posts.

In this post, I'll show you how to set up a blog on GitHub pages for free. I'll be demonstrating the Zola static site generator and using GitHub Actions to publish the site automatically every time you push to main, accept a pull request to main, or manually run the deployment workflow.
