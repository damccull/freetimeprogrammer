+++
title = "Rust Crates Every Developer Needs to Know"
date = 2022-05-04T13:08:00Z
updated = 2023-05-24T03:32:00Z

description = "A list of useful crates for the rust programming language."
aliases = ["/blog/rust-crates-every-developer-should-know/"]

[taxonomies]
tags = ["rust"]
categories = ["Programming"]

[extra]
ToC = true
+++

## Introduction

Picture this: you're chatting away on the rust official Discord server's #beginners channel, asking about your own problems while throwing out a nugget of your limited knowledge to those who are just beggining and are, right now, where you were a year ago. One of those new folks asks a question on how to do something that you're proud to have just recently figured out how to do so you begin typing up an explanation.

Out of the blue one of those amazing super-knowledgeable folks tosses out a crate name you've never heard of in response to that particular query so, confused, you go look up the crate. You find it does exactly what you were about to explain, only easier and with less code because now you're using a pre-built solution, and you wonder: _"Where is the list of these crates I wish I knew about?"_

This post strives to be that list. It is a categorized list of crates that I wish I'd known about and hope will help you out. You will find the crate's name, a small description, and a link to it on [crates.io][crates.io].

Some of these will be rust standard crates but most will probably be 3rd party crates. Feel free to send in submissions for consideration. I reserve full deciding rights on the inclusion of a suggestion.

## The Crates

### Async Runtimes

#### tokio - event-driven, non-blocking I/O platform

[[link](https://crates.io/crates/tokio)]

tokio is an async runtime framework. Rust only offers the basic building blocks to allow async code but does not include an async runner. That means users need a third party option, and tokio is the current king of those options. It offers a simple to use and well-designed API. It works on the concept of tasks, rather than threads, and a single thread may execute multiple tasks concurrently. Highly recommended if you need async code in Rust.

### Networking

#### h2 - low level HTTP/2 implementation

[[link](https://crates.io/crates/h2)]

h2 calls itself "a Tokio aware, HTTP/2 client & server implementation for Rust". It is not designed to act as a web server itself, though it can be used that way, but instead it's an implementation of the HTTP/2 specification that is very useful for building other frameworks on top.

#### reqwest

[[link](https://crates.io/crates/reqwest)]

An http client used for making requests over the http protocol. It is easy to use, quick, and supports TLS and plaintext. It can store cookies and supports WASM in some manner. The best part of reqwest is that it just works, and works easily.

### Path and URI Manipulation

#### camino - Unicode Path Types

[[link](https://crates.io/crates/camino)]

Taken from its own readme, "camino's Utf8PathBuf and Utf8Path types are like the standard library's PathBuf and Path types, except they are guaranteed to only contain UTF-8 encoded data. Therefore, they expose the ability to get their contents as strings, they implement Display, etc."

This is a useful crate for path manipulation on modern systems where you know they'll be formatted in unicode, like Windows, MacOS, and Linux.

### Web Servers

#### actix_web - async web server

[[link](https://crates.io/crates/actix-web)]

Actix Web claims to be a "Actix Web is a powerful, pragmatic, and extremely fast web framework for Rust". I have personally found it to be just that. It can be a bit difficult to understand at first but its power and speed are great and it works great with the tokio crate. Despite its speed it has a ton of built-in features and a massive support from 3rd party crates.

#### axum - async web server

[[link](https://crates.io/crates/axum)]

Axum calls itself "a web application framework that focuses on ergonomics and modularity". I used it to run through the book _Zero to Production in Rust_ and found it to be a joy to use. It is similar to actix_web in configuration but has a very different error handling model.

This web server integrates seamlessly with the `tower` crate because it's built on top of it. That allows users to automatically use any of the pre-existing `tower` middlewares right in their webserver.

Lastly, this crate is a member of the `tokio` family of crates. It is well maintained and actively developed.

#### hyper - low-level HTTP library

[[link](https://crates.io/crates/hyper)]
hyper is a low-level HTTP library used as a building block for other libraries. It is included here only because I regularly see example code for web servers that uses hyper directly rather than a more full-fledged web server framework.

#### rocket - highly-opinionated web server framework

[[link](https://crates.io/crates/rocket)]
Rocket focuses on ease of use and security. It's very extensible and pretty quick. It uses the tokio runtime for async operations as of version 0.5. It does not yet support websockets.

#### warp - very fast, fairly simple web server

[[link](https://crates.io/crates/warp)]
build on top of hyper, warp calls itself "a super-easy, composable, web server framework for warp speeds". It competes with actix in terms of speed and features but has a fundamentally different approach to setting up routing and passing the request through its infrastructure. It works very well with the tokio crate and has fairly decent 3rd party library support.

[crates.io]: https://crates.io "crates.io"
