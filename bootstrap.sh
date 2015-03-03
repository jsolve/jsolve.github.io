#!/usr/bin/env
yum -y install ruby
yum -y install gcc g++ make automake autoconf curl-devel openssl-devel zlib-devel httpd-devel apr-devel apr-util-devel sqlite-devel
yum -y install ruby-rdoc ruby-devel
## Centos 6
#yum -y install rubygems
gem install jekyll
yum -y install epel-release
yum -y install npm
yum -y install nodejs