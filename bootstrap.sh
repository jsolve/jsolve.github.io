#!/usr/bin/env bash
yum -y install ruby
yum -y install gcc g++ make automake autoconf curl-devel openssl-devel zlib-devel httpd-devel apr-devel apr-util-devel sqlite-devel
yum -y install ruby-rdoc ruby-devel

gem install jekyll
yum -y install epel-release
yum -y install npm
yum -y install nodejs
