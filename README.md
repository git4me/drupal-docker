# Docker + Composer template for Drupal projects

This is a local development stack for Drupal projects using docker.

This is based on  [drupal-composer/drupal-project](https://github.com/drupal-composer/drupal-project).

## How to use this
Because the traditional docker host ip 172.x.x.x won't work in OSX or windows you need to setup alias IP-address `10.254.254.254` for the hostmachine. This needs to be done so that this dev environment works similarly in all environments.

Also without this hack docker containers can't connect back to xdebug IDE running in OSX.

## How to setup localhost alias 10.254.254.254
**OSX/FreeBSD:**
```
$ ifconfig lo alias 10.254.254.254
```

**Linux:**
```
$ ifconfig lo:0 10.254.254.254 up
```

You need to do this everytime after booting the machine.

## Setup DNS name resolver for *.test addresses
**OSX**
```
$ echo "nameserver 10.254.254.254" | sudo tee /etc/resolver/test
$ echo "domain test" | sudo tee -a /etc/resolver/test
$ sudo killall -HUP mDNSResponder
```

**Ubuntu with dnsmasq**
```
$ echo server=/test/10.254.254.254 | sudo tee /etc/NetworkManager/dnsmasq.d/test-dns
$ sudo service network-manager restart
```

## How to start developing
```
$ make install
```

## Maintainers
[Onni Hakala](https://github.com/onnimonni)

## License

GPLv2