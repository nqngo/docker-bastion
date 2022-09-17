#!/usr/bin/env sh

# Generate host keys on first run
if [ ! -f "/etc/ssh/hostkeys/ssh_host_rsa_key" ]; then
    ssh-keygen -q -N "" -t ed25519 -f /host_keys.d/ssh_host_ed25519_key
    ssh-keygen -q -N "" -t rsa -b 4096 -f /host_keys.d/ssh_host_rsa_key
    ssh-keygen -q -N "" -t ecdsa -f /host_keys.d/ssh_host_ecdsa_key
fi

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


# Start sshd
/usr/sbin/sshd -D -e \
    $OPT_X11_FORWARDING \
    $OPT_LISTEN_PORT