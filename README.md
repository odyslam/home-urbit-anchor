# Home-Urbit Anchor

This Docker container generates a single-user Wireguard server using the $PUBKEY env var provided to it.

It is meant to run alongside [home-urbit](https://github.com/OdysLam/home-urbit)'s anchor component, enabling Home-Urbit to be exposed to the Internet but be hosted on a local internet. It's an easy-to-setup alternative to using a VPN solution.


## Instructions

- Run Home-Urbit and get the public key from the anchor client
- Provision a Linux VM from a provider (e.g Digital Ocean, Hetzner, etc.), boot it up and install Docker.
- Make the public key available to the Docker instance by running `expose PUBKEY=<PUBLIC_KEY>`, where `<PUBLIC_KEY>` is your public key
- Clone this repository `git clone https://github.com/odyslam/home-urbit-anchor-server`
- `cd home-urbit-anchor-server`
- Run:

**Use Docker**
```
docker run --privileged --cap-add=SYS_MODULE --cap-add=NET_ADMIN --sysctl net.ipv4.ip_forward=1 --sysctl net.ipv4.conf.all.src_valid_mark=1 -v ${HOME}/wg:/etc/wg --env #{PUBKEY} --expose 51820:51820/udp odyslam/home-urbit-anchor:latest
```
**Use Docker-compose**
```
docker-compose up
```

The anchor server should boot up and now you can easily access your urbit from the IP of the machine that runs the anchor server.

It is meant to be rough around the edges, as it's the core of a wider SASS platform that can be built on top of it, where a user can easily provision a domain-name and an anchor server, without having to set anything up. The SASS platform is out of scope of the MVP implementation.

## Kudos

- Thanks to @yapishu for helping out with implementing this
- Thanks to Urbit Foundation for assisting in the implementation of the Home-Urbit suite

## License

MIT

