#!/bin/bash

set -e
set -x
export DEBIAN_FRONTEND=noninteractive
aptinstall="apt-get install --no-install-recommends --yes"

# Temporarily disable dpkg fsync to make building faster.
echo force-unsafe-io > /etc/dpkg/dpkg.cfg.d/02-unsafe-io

# Remove cached deb archives after package installation
echo 'DPkg::Post-Invoke {"/bin/rm -f /var/cache/apt/archives/*.deb || true";};' > /etc/apt/apt.conf.d/99-no-cache

# Prevent initramfs updates from trying to run grub and lilo.
# https://journal.paul.querna.org/articles/2013/10/15/docker-ubuntu-on-rackspace/
# http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=594189
export INITRD=no
mkdir -p /etc/container_environment
echo -n no > /etc/container_environment/INITRD

# Enable Ubuntu Universe and Multiverse.
sed -i 's/^#\s*\(deb.*universe\)$/\1/g' /etc/apt/sources.list
sed -i 's/^#\s*\(deb.*multiverse\)$/\1/g' /etc/apt/sources.list

# Fix some issues with APT packages.
# See https://github.com/dotcloud/docker/issues/1024
dpkg-divert --local --rename --add /sbin/initctl
ln -sf /bin/true /sbin/initctl

# Replace the 'ischroot' tool to make it always return true.
# Prevent initscripts updates from breaking /dev/shm.
# https://journal.paul.querna.org/articles/2013/10/15/docker-ubuntu-on-rackspace/
# https://bugs.launchpad.net/launchpad/+bug/974584
dpkg-divert --local --rename --add /usr/bin/ischroot
ln -sf /bin/true /usr/bin/ischroot

# Replace start stop and restart commands with wrapper to supervisorctl
rm /sbin/{start,stop,restart}
for file in start stop restart
do
    ln -s /usr/local/sbin/servicewrapper /usr/local/sbin/$file
done

# Update package lists
apt-get update

# Set UTF8 locale
$aptinstall language-pack-en
echo LC_ALL="en_US.utf8" >> /etc/environment

# Upgrade all packages
apt-get dist-upgrade --no-install-recommends --yes

# Install common and required packages
$aptinstall python python-dev python-virtualenv python-pip python-pexpect build-essential \
            ca-certificates apt-transport-https software-properties-common \
            openssh-server supervisor cron vim syslog-ng-core

# Replace the system() source because inside Docker we
# can't access /proc/kmsg.
sed -i -E 's/^(\s*)system\(\);/\1unix-stream("\/dev\/log");/' /etc/syslog-ng/syslog-ng.conf

# Install ansible
virtualenv --python /usr/bin/python2 /opt/ansible
/opt/ansible/bin/pip install ansible
mkdir /etc/ansible
ln -s /opt/ansible/hosts /etc/ansible/hosts
ln -s /opt/ansible/ansible.cfg /etc/ansible/ansible.cfg
ln -s /opt/ansible/bin/ansible /usr/local/bin/ansible
ln -s /opt/ansible/bin/ansible-playbook /usr/local/bin/ansible-playbook
ln -s /opt/ansible/bin/ansible-doc /usr/local/bin/ansible-doc
ln -s /opt/ansible/bin/ansible-galaxy /usr/local/bin/ansible-galaxy
ln -s /opt/ansible/bin/ansible-pull /usr/local/bin/ansible-pull
ln -s /opt/ansible/bin/ansible-vault /usr/local/bin/ansible-vault

rm /etc/dpkg/dpkg.cfg.d/02-unsafe-io
rm -rf /var/lib/apt/lists/*
