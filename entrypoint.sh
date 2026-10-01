#!/usr/bin/env sh

# Generate host keys on first run
if [ ! -f "/host_keys.d/ssh_host_ed25519_key" ]; then
    ssh-keygen -q -N "" -t ed25519 -f /host_keys.d/ssh_host_ed25519_key
fi

# Ensure gnupg directory exists for GPG socket forwarding
mkdir -p /home/bastion/.gnupg
chmod 700 /home/bastion/.gnupg
chown bastion:bastion /home/bastion/.gnupg

# Fetch a remote public ssh key file and store in bastion authorized_keys
if [ -n "${REMOTE_SSH_URL}" ]; then
    su - bastion -c "curl -sS ${REMOTE_SSH_URL} -o /home/bastion/.ssh/authorized_keys"
    echo "[bastion] Added ${REMOTE_SSH_URL} ssh keys to authorized_keys file."
fi

# Fetch a remote GPG public key file and import them to bastion keyring
if [ -n "${REMOTE_GPG_URL}" ]; then
    su - bastion -c "curl -sSf ${REMOTE_GPG_URL} | gpg --import -"
    echo "[bastion] Imported GPG keys from ${REMOTE_GPG_URL}."
fi

# Configure sshd options
if [ -n "${ALLOW_X11_FORWARDING}" ]; then
    OPT_X11_FORWARDING="-o X11Forwarding=yes"
else
    OPT_X11_FORWARDING="-o X11Forwarding=no"
fi
if [ -n "${LISTEN_PORT}" ]; then
    OPT_LISTEN_PORT="-o Port=${LISTEN_PORT}"
else
    OPT_LISTEN_PORT="-o Port=22"
fi
if [ -n "${PERMIT_TUNNEL}" ]; then
    OPT_TUNNEL="-o PermitTunnel=${PERMIT_TUNNEL}"
else
    OPT_TUNNEL="-o PermitTunnel=no"
fi


# Start sshd
/usr/sbin/sshd -D -e \
    $OPT_X11_FORWARDING \
    $OPT_LISTEN_PORT \
    $OPT_TUNNEL