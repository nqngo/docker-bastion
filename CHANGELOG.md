## 2026-10-1
----------------
docker.io/alpine@sha256:294b683cb724975bec92580e1e685676bd4b50bda910ddb8c51d4cabeaec77e6
- openssh-server-10.3_p1-r1
- openssh-client-10.3_p1-r1
- gnupg-2.4.9-r1
- curl-8.22.0-r0

### Modernization & Security Hardening (PR #22):
- **Post-Quantum Cryptography**: Uplifted KEX to modern post-quantum hybrid algorithms (`mlkem768x25519-sha256`, `sntrup761x25519-sha512@openssh.com`) and RFC 8731 `curve25519-sha256`, resolving post-quantum warnings in OpenSSH 10.x.
- **Host Key Modernization**: Migrated to Ed25519-only host key (`/host_keys.d/ssh_host_ed25519_key`), removing legacy 4096-bit RSA and ECDSA keys for faster startup and cleaner security.
- **SFTP Subsystem**: Switched from broken external `/usr/lib/ssh/sftp-server` binary path to OpenSSH built-in `internal-sftp`.
- **Package Additions**: Added `openssh-client` to the container image to enable native in-container SSH and key management.
- **Authentication Hardening**: Explicitly disabled password and keyboard-interactive authentication fallbacks (`PasswordAuthentication no`, `KbdInteractiveAuthentication no`).
- **Session Lifecycles & Forwarding**: Configured `ClientAliveInterval 300`, `ClientAliveCountMax 2` (terminating dead sessions and stale GPG sockets), `LoginGraceTime 30`, and `MaxAuthTries 3`.
- **Entrypoint Bug Fix**: Fixed host key path check to `/host_keys.d/ssh_host_ed25519_key` so persistent volumes preserve existing host keys across container restarts.
- **Tunneling Flexibility**: Added `PERMIT_TUNNEL` runtime environment variable.
- **GPG Socket Forwarding**: Ensured `/home/bastion/.gnupg` directory is created with mode `0700` during build and container initialization so GPG socket forwarding succeeds.
- **Automated Testing Suite**: Staged modular automated test harness in `tests/` covering SFTP, agent forwarding, GPG socket unlinking, and host key algorithms.
- **CI/CD Integration**: Added automated GitHub Actions test workflow on push and pull requests, and a release test gate.

## 2026-10
----------------
docker.io/alpine@sha256:294b683cb724975bec92580e1e685676bd4b50bda910ddb8c51d4cabeaec77e6
- openssh-server-10.3_p1-r1
- gnupg-2.4.9-r1
- curl-8.22.0-r0

## 2026-09
----------------
docker.io/alpine@sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b
- openssh-server-10.3_p1-r1
- gnupg-2.4.9-r1
- curl-8.21.0-r0

## 2026-08
----------------
docker.io/alpine@sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b
- openssh-server-10.3_p1-r0
- gnupg-2.4.9-r1
- curl-8.21.0-r0

## 2026-07
----------------
docker.io/alpine@sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b
- openssh-server-10.3_p1-r0
- gnupg-2.4.9-r1
- curl-8.21.0-r0

## 2026-04
----------------
docker.io/alpine@sha256:25109184c71bdad752c8312a8623239686a9a2071e8825f20acb8f2198c3f659
- openssh-server-10.2_p1-r0
- gnupg-2.4.9-r0
- curl-8.17.0-r1

## 2026-01
----------------
docker.io/alpine@sha256:865b95f46d98cf867a156fe4a135ad3fe50d2056aa3f25ed31662dff6da4eb62
- openssh-server-10.2_p1-r0
- gnupg-2.4.8-r1
- curl-8.17.0-r1

## 2025-07
----------------
docker.io/alpine@sha256:8a1f59ffb675680d47db6337b49d22281a139e9d709335b492be023728e11715
- openssh-server-10.0_p1-r7
- gnupg-2.4.7-r0
- curl-8.14.1-r1

## 2025-06
----------------
docker.io/alpine@sha256:8a1f59ffb675680d47db6337b49d22281a139e9d709335b492be023728e11715
- openssh-server-10.0_p1-r7
- gnupg-2.4.7-r0
- curl-8.14.0-r2

## 2025-05
----------------
docker.io/alpine@sha256:a8560b36e8b8210634f77d9f7f9efd7ffa463e380b75e2e74aff4511df3ef88c
- openssh-server-9.9_p2-r0
- gnupg-2.4.7-r0
- curl-8.12.1-r1

## 2025-04
----------------
docker.io/alpine@sha256:a8560b36e8b8210634f77d9f7f9efd7ffa463e380b75e2e74aff4511df3ef88c
- openssh-server-9.9_p2-r0
- gnupg-2.4.7-r0
- curl-8.12.1-r1

## 2025-03
----------------
docker.io/alpine@sha256:a8560b36e8b8210634f77d9f7f9efd7ffa463e380b75e2e74aff4511df3ef88c
- openssh-server-9.9_p2-r0
- gnupg-2.4.7-r0
- curl-8.12.1-r0

## 2025-02
----------------
docker.io/alpine@sha256:56fa17d2a7e7f168a043a2712e63aed1f8543aeafdcee47c58dcffe38ed51099
- openssh-server-9.9_p1-r2
- gnupg-2.4.7-r0
- curl-8.11.1-r0

## 2025-01
----------------
docker.io/alpine@sha256:21dc6063fd678b478f57c0e13f47560d0ea4eeba26dfc947b2a4f81f686b9f45
- openssh-server-9.9_p1-r2
- gnupg-2.4.7-r0
- curl-8.11.1-r0

## 2024-11
----------------
docker.io/alpine@sha256:beefdbd8a1da6d2915566fde36db9db0b524eb737fc57cd1367effd16dc0d06d
- openssh-server-9.7_p1-r4
- gnupg-2.4.5-r0
- curl-8.10.1-r0
