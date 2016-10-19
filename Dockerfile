FROM fedora:24

ADD aapl.patch /aapl.patch
RUN dnf install -y avahi supervisor git gcc python python-devel gnutls-devel libacl-devel openldap-devel \
    && dnf clean all \
    && git clone https://github.com/samba-team/samba.git \
    && cd samba \
    && git apply /aapl.patch \
    && ./configure \
    && make -j4 \
    && make install \
    && mkdir -p /usr/local/samba/var/lock \
    && mkdir -p /usr/local/samba/private \
    && sed -i 's|#enable-dbus=yes|enable-dbus=no|' /etc/avahi/avahi-daemon.conf \
    && cd / \
    && rm -rf /samba
ADD timemachine.service /etc/avahi/services/timemachine.service
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD smb.conf /etc/samba/smb.conf
RUN ["chmod","777","/srv"]
VOLUME ["/usr/local/samba/private/", "/srv"]
EXPOSE 5353 445
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

