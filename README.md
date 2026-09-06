<!--
Copyright (C) 2026 Maxim [maxirmx] Samsonov ([www.sw.consulting](http://www.sw.consulting))
All rights reserved.
-->

# sw-consulting-edge

Neutral HTTPS edge for applications hosted on the shared sw.consulting server.
It owns public ports 80 and 443 and routes requests to independently managed
application UI containers over the `sw-consulting-edge` Docker network.

## Host preparation

Create the following files outside the repository:

```text
/srv/sw-consulting-edge/certificate/s.crt
/srv/sw-consulting-edge/certificate/s.key
```

The single certificate must cover all demo projects, normally through the `*.sw.consulting` wildcard name.
Protect `s.key` and `edge.env` with mode `0600`.

```sh
cp edge.env.example edge.env
chmod +x scripts/bootstrap.sh scripts/update.sh
scripts/bootstrap.sh
```

The edge can start before the applications. A missing application returns a
502 for its hostname without affecting the edge or other applications.

## Updates

```sh
scripts/update.sh
```

## Releases

Push a semantic-version tag to create a GitHub Release containing the deployable
project files as a `.tar.gz` archive and a SHA-256 checksum:

```sh
git tag v0.1.0
git push origin v0.1.0
```

Application stacks attach only their UI services to the external network using
aliases like `klinok-ui`, `sarafan-ui` and `sarafan-backoffice`. APIs and databases stay private.

The Sarafan back office is served at `sb.sw.consulting`, using the
`sarafan-backoffice:8080` alias supplied by Sarafan Core’s edge Compose overlay.
Point its DNS record at the edge host and include it in the TLS certificate.
Its upstream resolves at request time, so an unavailable back office does not
prevent the edge or customer applications from starting.
