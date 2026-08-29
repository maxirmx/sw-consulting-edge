# sw-consulting-edge

Neutral HTTPS edge for applications hosted on the shared sw.consulting server.
It owns public ports 80 and 443 and routes requests to independently managed
application UI containers over the `sw-consulting-edge` Docker network.

## Host preparation

Create the following files outside the repository:

```text
/srv/sw-consulting-edge/certificates/klinok/tls.crt
/srv/sw-consulting-edge/certificates/klinok/tls.key
/srv/sw-consulting-edge/certificates/sarafan/tls.crt
/srv/sw-consulting-edge/certificates/sarafan/tls.key
```

Each certificate must cover its corresponding public hostname. Protect private
keys and `edge.env` with mode `0600`.

```sh
cp edge.env.example edge.env
chmod +x scripts/bootstrap.sh scripts/update.sh
scripts/bootstrap.sh
```

The edge can start before either application. A missing application returns a
502 for its hostname without affecting the edge or the other application.

## Updates

```sh
scripts/update.sh
```

Application stacks attach only their UI services to the external network using
the aliases `klinok-ui` and `sarafan-ui`. APIs and databases stay private.
