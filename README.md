# List of my demo projects and tutorials

## LLM YouTube Moderator Bot

This Python script provides an automated solution for moderating live YouTube chat comments using a local Large Language Model (LLM) via LM Studio. The bot can detect and delete comments that are deemed inappropriate based on a configurable system prompt.

https://github.com/creotiv/youtube-llm-moderator

## Kubernetes (K8S) Sidecar containers demo

Small demo to show the power of the sidecars in K8S. How to optimize deployment strategy with them, and simplyfy developing of new services

https://github.com/creotiv/sidecar-demo

## Custom Approval Management for GitHub

This GitHub Action enables the addition of various teams and their members to the approval process, specifying the required number of members from each team. This is particularly useful, for example, when orchestrating a production deployment that requires explicit approval from the QA team, Product team, Development team, etc., making the process straightforward, simple, and transparent.

https://github.com/creotiv/custom-approval-management

## Demo for gracefull K8S rollout without outage

During a rolling update, Kubernetes updates pods with a new version in a controlled way, terminating old pods and starting new ones. The key to a smooth update is ensuring that the old pods don't get terminated before they've finished handling their current connections. Kubernetes sends a SIGTERM signal to the containers in the pod to initiate a graceful shutdown, followed by a SIGKILL signal after a grace period. But when the SIGTERM signal sent in parallel there could be ongoing request that will hit container which already shutdown. This is open issue in k8s right now.

Read more here about the problem: https://www.alibabacloud.com/blog/enabling-rolling-updates-for-applications-in-kubernetes-with-zero-downtime_596717

https://github.com/creotiv/github.com-creotiv-k8s-rollout-test

## Go Gracefull upgrade using DEB packages & Systemd

https://github.com/creotiv/architecture/tree/master/approaches/graceful-upgrade

## Demo of console screensaver

https://github.com/creotiv/snowua

## How to make bootable image with only golang binary

Just in case you want to try something trully different :)

https://github.com/creotiv/howto-bootable-golang-binary

## Demo implementation of Blockchain node based on PoW (aka bitcoin)

For Article: https://medium.com/p/848ef33d7448

In this article, I want to cover a simplified but working example of decentralized Blockchain based on Proof Of Work algorithm, some sort of simplified Bitcoin. You can think about it as a simplified version of Bitcoin.

https://github.com/creotiv/full_node_blockchain

## Reverse-Engineering of MiBand2 protocol

For Article: https://medium.com/machine-learning-world/how-i-hacked-xiaomi-miband-2-to-control-it-from-linux-a5bd2f36d3ad

This is a step by step guide into how I hacked my Bluetooth Low Energy (BLE) fitness tracker so I could control it from Linux.

https://github.com/creotiv/MiBand2

## Mysterium Network dVPN tutorial. Making desktop client application.

In this tutorial we will show how to build a simplest desktop dVPN application based on Electron framework, and will cover main parts of dVPN client, to give you understanding how they interract.

https://github.com/creotiv/dvpn-tutorial-mysterium-network

## Demo for deploying small app with Docker & Fabric

For article  https://hackernoon.com/deploying-on-aws-free-tire-with-docker-and-fabric-d9eca7c629e6

https://github.com/creotiv/aws-docker-example

## Migrated to PyTorch HDRNet model for photo editing

Fore some reason it doesn't work, i talked with author of the paper, and it seems there were some internal difference in PyTorch itself which leading to dying gradient.
Too problematic to debug it for no reason, while still good thing to learn 

https://github.com/creotiv/hdrnet-pytorch




