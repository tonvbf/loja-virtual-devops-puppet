#!/bin/sh
set -e -x
export DEBIAN_FRONTEND=noninteractive
wget https://apt.puppetlabs.com/puppet-release-xenial.deb
dpkg -i puppet-release-xenial.deb
apt-get -y update
apt-get -y install puppet-agent facter
