# clamav-docker

## Overview

This docker image contains [ClamAV](https://www.clamav.net/).

## Entrypoint Scripts

### clamav

The embedded entrypoint script is located at `/etc/entrypoint.d/clamav` and performs the following actions:

2. A new clamav configuration is generated using the following environment variables:

 | Variable | Default Value | Description |
 | -------- | ------------- | ----------- |

## Healthcheck Scripts

### clamav

The embedded healthcheck script is located at `/etc/healthcheck.d/clamav` and performs the following actions:

1. Verifies that all clamav services are operational.

## Standard Configuration

### Container Layout

```
/
├─ etc/
│  ├─ clamav/
│  ├─ entrypoint.d/
│  │  └─ clamav
│  └─ healthcheck.d/
│     └─ clamav
└─ usr/
   ├─ bin/
   │  └─ clamdtop
   └─ local/
      └─ bin/
         └─ clamav-scan-media
```

### Exposed Ports

* `3310/tcp` - clamav server listening port
* `7357/tcp` - clamav milter listening port

### Volumes

* `/etc/clamav` - clamav configuration directory.
* `/var/lib/clamav` - clamav database directory.

## Development

[Source Control](https://github.com/crashvb/clamav-docker)

