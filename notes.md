# Anchor client container

### Dockerfile 

Downloads wireguard in first layer

copies to second layer

installs a bunch of packages -- curl, iptables ,python, iproute

moves to app dir, downloads wg tools

runs buildmod script

    checks for wg kernel module

    checks for balena vars and builds k modules if present

    downloads from balena & builds

copies in conf templates

downloads prips script

    script prints a list of ip addresses in a given block

copies in run script

copies in show-peer script

copies in default peer config (not present?)

runs the run script

    (see below)

sets default network vars for configs

### run.sh

this script is for creating a wg server

sets up initial wg server config

builds wg kernel module

tries to use userscape module if kernel module is unavailable

generates server keys, executes ipcalc to calculate bounds of cidr and assign server to lowest address

generates list of available IPs with prips script

uses envsubst to modify the server template config

generate a list of numbers from $PEER

print a default peer config to the server

bring up the wg interface


# chto delat

### server software

container layer and host layer

    host contains persistent client data and account management?

    container runs the wg server


### client software 

orchestrator runs on the peer and passes config/whatever else to the containers via volume

    [not determined yet -- how client receives auth key]

    server receives some trigger from payment mechanism incl. client email

    server generates an auth key, saves to db & passes it to client via email

    some kind of client-side initiation trigger: client generates pubkey and submits with auth

    anchor validates auth token
    
        check db for auth token
        
            error response to client?

        find next available IP

        write pubkey, IP & timestamp to db row
    
    generates next available vpn peer config

    appends peer to server conf & restarts interface

    convert peer config to base64 and send back

    client receives peer config, writes to file & enables interface

some kind of cron that checks whether auth is expired and cleans up db entries

    email when subscription is lapsing? would be great if we could send a message on-network somehow

#### transaction schema

#### database

easier to work with than parsing the server conf

sqlite db:

    table: peers

        columns: auth token, pubkey, ip, timestamp, expiration