+++
title = "Run a Full Signum Node on Windows or Linux"
date = 2021-05-01T14:06:00Z
updated = 2022-09-15T13:16:00Z

description = "Learn how to support the Signum network by setting up and running a full Signum node on your computer."
aliases = ["/blog/run-a-full-burstcoin-node/"]

[taxonomies]
tags = ["Signum", "Proof of Capacity"]
categories = ["CryptoCurrency"]
+++

<note>
  <ul>
    <li>Update (<datetime>2022-09-15T13:16:00Z</datetime>): Updated names of binary files, changed the docker image to the official image, updated NDS-A references to SNA, and reworded some of the information about the Burstcoin to Signum rebrand.</li>
    <li>Update (<datetime>2021-07-17T16:15:00Z</datetime>): This article originally talked about Signum's old names: Burstcoin, Burst, and Burst Reference Software (BRS). It has been updated to reference Signum and Signum Node (for the software) in most places. A portion of the background was rewritten to be more relevant, and links were updated to point at new Signum locations.</li>
  </ul>
</note>

## A Bit of Background

### Traditional Cryptocurrency

Cryptocurrencies are all the rage these days. A single Bitcoin is worth the price of a small house in some places, or more than a single car most everywhere. Bitcoin is a major success story for cryptocurrencies, but it and other coins like it have a pretty major impact on the consumption of electricity.

Estimates show Bitcoin using more electricity than some small countries if you total the entire consumption from all nodes across the world. That's a lot of power being used, and unless we happen across a signicant reduction in the cost of electricity, eventually it will become unsustainable. There are alternatives.

### Proof of Capacity Cryptocurrency

Proof of Capacity cryptocurrencies offer a much reduced electrical footprint by trading the Proof of Work algorithms for an algorithm that pre-computes most of the necessary data only once and stores it on hard drives. Then, when it's time to create a new entry in the distributed database, the miners search specific places on the hard drives, do a little math on the values found there, and produce a 'deadline', which is simply a number in seconds until the next block in the blockchain can be created.

A recent entry into the Proof of Capacity space is a coin called Chia, supposedly created by the creator of bit torrent. It has done quite a bit to popularize the incredibly small environmental impact of Proof of Capacity. However, it's the new kid on the block and isn't pure Proof of Capacity as it also takes into account time.

The original Proof of Capacity cryptocurrency, Signum (formerly known as Burstcoin), started running at 10pm GMT on the 10th of August, 2014. A new block is forged approximately every 4 minutes and the blockchain is at block 878078 as of the writing of this article. Signum has been running stable for many years. It's an open source, community driven project with several different wallet softwares and a Smart Contract system that lets programs run in the blockchain itself. As of block 878000, Signum is no longer exclusively Proof of Capacity either, but now encourages staking your coins to provide a boost to mining.

### Burstcoin to Signum Rebrand

Burstcoin was rebranded to Signum in an effort to create a stronger, more recognizable identity. The blockchain remains the same historical, stable chain it was prior. As mentioned above, Signum is not a pure proof of capacity, but is now referred to as a proof of commitment network. The recent changes in allowing miners to commit their earnings back into the mining process (without risk of loss) helps to further secure the chain against attacks and allows small miners the opportunity to actually earn coins, rather than competing with massive miners and earning next to nothing.

With all that background out of the way, let's set up a full node for Signum.

You can use the same download for both Windows and Linux because Signum's current software is written in Java. [Download the latest zip release here][signum-download] and unzip it to anywhere on your PC.

## Windows is Easy Peasy

The Windows setup is super easy. Open the folder you just unzipped and double click the `signum-node.exe` file. If you don't have Java installed, you will be notified that it's a requirement and a browser will open to the download page. You can feel free to install Java globally through the downloads on that website.

If you're like me, however, you believe Java is a giant security hole that should never be installed globally. You can, as an alternative, download a portable Java installation and set up a batch file to launch the Signum node from the portable Java with these instructions:

1. Download [jPortable from here][jportable] and launch the installer
    1. Select you language of choice
    2. Click `Next`, then agree to the terms
    3. Create a new folder called `Java` in your Signum folder (right next to Signum.exe)
    4. Set the `Destination Folder` to the Java folder you just created and click `Install`
2. Create a new file in the Signum folder (right next to Signum.exe) and name it `signum.bat`
3. Open `signum.bat` in a text editor and copy this command into it, then save and close it:

    ```batch
    start .\Java\bin\javaw.exe -jar signum-node.jar
    ```

4. Double click `signum.bat` and you should see the BRS log window appear.

Congratulations, you've installed and started the Signum Reference Software for the first time. After a couple seconds of it running, 3 buttons will appear. The node will function fully as is but there is an opportunity to earn a few free Signums per day from the NDS-A. Scroll past the Linux section to read up on how.

## Linux is Also Easy...and Harder, Depending

Earlier I mentioned that you can use the same download for both Windows and Linux. Under Linux you'll launch the burst.jar file directly by running `java -jar signum-node.jar` from inside the Signum folder using a terminal. You could probably also make the jar file executable by typing `chmod +x signum-node.jar` and then double-clicking it in the file explorer.

Or you could use Docker. I will show you how to run the Signum Node in docker because it makes things easy and provides the same environment for all Linux platforms, regardless of the distribution. This way will also run headless. You won't get the same console UI you see in the Windows version.

There are some prerequisites for doing this:

1. You have to install Docker. Do not use the Snap package as it does not work for this. Install Docker using [their official installation instructions][docker-install-instructions]. Here's a shortcut to the [Ubuntu installation instructions][docker-install-instructions-ubuntu].
2. You also have to install docker-compose. [Follow the instructions here][docker-compose-install].
3. Open a terminal or console.
4. Type `mkdir ~/Signum && cd ~/Signum` to create and navigate to a new folder in your home folder.
5. Type `nano -w docker-compose.yml` to create a new file and open it. Paste the following in there.

    ```yml
    version: "3.8"
    services:
      brs:
        image: signumnetwork/node:latest-h2
        deploy:
          replicas: 1
        restart: always
        ports:
          - "8121:8121"
          - "8123:8123"
          - "8125:8125"
        volumes:
          - "./brs.properties:/brs/conf/brs.properties"
          - burst_db:/brs/burst_db
        logging:
          driver: "json-file"
          options:
              max-file: "5"
              max-size: "10m"
    volumes:
      burst_db:
        external: true
    ```

6. Press `ctrl-x` then `y` to close and save the file.
7. Type `docker-compose up -d` to launch the Signum Node software.
8. You may now browse to "localhost:8125" and log into either the Phoenix or Classic wallets.

Congratulations, you've installed and started the Signum Reference Software, running headless under Docker. The node will function fully as is but there is an opportunity to earn a few free Signums per day from the NDS-A. See the next section on how.

You'll need to shut down the Signum Node and restart it if you make configuration changes in the brs.properties file. You can do that with `docker-compose down` while in the Signum folder.

## Signum Network Association Awards (SNA)

Back in December, 2018, an organization called the Signum Network Association (formerly known as the Burst Marketing Fund) started giving out payments to all full node operators who met specific requirements. It's still going on and will net you a couple free Signa per day just for operating a full node, which is what you set up earlier. Might as well get paid for it.

<note>Note: Signum, at the time of this writing, has a very low price. So low that the SNA reward will not be worth any real money at this time. Don't count on making a profit from this anytime soon.</note>

To start earning the SNA, you need to ensure a few things are set up properly.

1. You need the latest version of the Signum Node. You just downloaded and set this up so you should be fine there.
2. You need to make a few changes in your configuration file.
    1. In the Signum Node window, click the `Edit conf file` button. It should open a text editor to the configuration file.
    2. In the Signum Node window, also click the `Phoenix Wallet` button. It will open a web page to the new Phoenix Signum wallet. Either create a new account or import an existing one. If you're setting up a full node, you probably already have an account. If not, please ask on the official [Discord][discord-join-link] for help getting this done.
    3. Log into the Phoenix wallet with your account.
    4. On the top left of the Phoenix wallet is a pretty little icon below your Signum address. Copy the Signum address by either selecting it and pressing CTRL-C on the keyboard, or clicking the dropdown below the icon and clicking `Copy Address`.
    5. In the configuration file you opened in step 1, find the line that says `P2P.myPlatform = PC` and replace the `PC` portion with your Signum address.
    6. Still in the configuration file, find the line that says `P2P.shareMyAddress =` and change it to say `P2P.shareMyAddress = yes`.
    7. UPnP might automatically work, but I suggest following your router's instructions (found on the internet) to manually forward port `8123` to the computer running this new Signum Node node.
    8. Ensure your node stays up all the time. SNA only distributes to online nodes.
3. Lastly, check the [NotAllMine.net Signum Network Explorer](https://explorer.notallmine.net/peers/) and search for your IP or your Signum address. Click the link for your peer and you can see the reward status information along with a bunch of other info about your node. Note that it may take a while to show up in this list.

<note>Note: You will not receive SNA awards until your node is FULLY SYNCHRONIZED with the network. That can take several hours to a day. You can follow the status of your sync by watching the percentage progress bar in the bottom right of the Signum Node console window.</note>

## End of Line

In this article, I explained how to fully set up a Signum full node and even earn yourself some SNA Signums. There's a lot I didn't cover, so if you have additional questions, please join the community on [Discord][discord-join-link], or you can check out the [official documentation on starting up a node][official-node-docs].

[signum-download]: https://github.com/signum-network/signum-node/releases/latest "Signum Downloads"
[jportable]: https://portableapps.com/apps/utilities/java_portable "jPortable"
[docker-install-instructions]: https://docs.docker.com/install/ "Docker Install Instructions"
[docker-install-instructions-ubuntu]: https://docs.docker.com/install/linux/docker-ce/ubuntu/ "Docker Install Instructions for Ubuntu"
[docker-compose-install]: https://docs.docker.com/compose/install/#install-compose-on-linux-systems "Install docker-compose on Linux"
[discord-join-link]: https://discord.gg/eVFRx7DECX "Official Signum Discord"
[official-node-docs]: https://docs.signum.network/signum/starting-a-signum-node "Starting a Signum Node"
