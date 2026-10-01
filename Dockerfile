FROM alpine:latest AS install_packages
ARG VERSION
LABEL maintainer="Nhat Ngo"
LABEL version=$VERSION
RUN apk add --update --no-cache openssh-server openssh-client gnupg curl
RUN mkdir -p /host_keys.d

FROM install_packages AS add_user_bastion
RUN adduser -D bastion
RUN mkdir -p /home/bastion/.ssh /home/bastion/.gnupg
RUN chmod 700 /home/bastion/.ssh /home/bastion/.gnupg
RUN chown -R bastion:bastion /home/bastion/.ssh /home/bastion/.gnupg
RUN echo "bastion:$(echo $RANDOM | md5sum | cut -c-32)" | chpasswd

FROM add_user_bastion AS set_config_file
COPY sshd_config /etc/ssh/sshd_config
COPY entrypoint.sh ./

EXPOSE 22/tcp

ENTRYPOINT ["./entrypoint.sh"]