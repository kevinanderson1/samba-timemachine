FROM fedora:26

RUN dnf install -y avahi avahi-devel git gcc python python-devel gnutls-devel libacl-devel openldap-devel pam-devel \
    && dnf clean all \
    && git clone https://github.com/kevinanderson1/samba.git \
    && cd samba \
    && git fetch origin \
    && git checkout remotes/origin/bz12380-full_fsync \
    && ./configure \
    && echo "Using $(nproc) cpu's for compilation" \
    && make -j$(nproc) \
    && make -j$(nproc) install \
    && mkdir -p /usr/local/samba/var/lock \
    && mkdir -p /usr/local/samba/private \
    && cd / \
    && rm -rf /samba \
    && dnf remove -y git gcc gnutls-devel libacl-devel openldap-devel pam-devel

ADD createUsers.sh /etc/supervisor/createUsers.sh
ADD smb.conf /etc/samba/smb.conf
ADD smbd.service /etc/systemd/system/smbd.service

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;
ADD avahi-systemd.override.conf /etc/systemd/system/avahi-daemon.service.d/override.conf
ADD systemd-tmpfiles-setup.override.conf /etc/systemd/system/systemd-tmpfiles-setup.service.d/override.conf
ADD create-users.service /etc/systemd/system/create-users.service
RUN systemctl enable smbd avahi-daemon create-users

VOLUME [ "/sys/fs/cgroup" ]
RUN ["chmod","777","/srv"]
VOLUME ["/usr/local/samba/private/", "/srv"]
EXPOSE 5353 445

CMD ["/usr/sbin/init"]
