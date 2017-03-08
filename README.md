# Testbox for puppet module typo3

[![No Maintenance Intended](http://unmaintained.tech/badge.svg)](http://unmaintained.tech/)

## Usage

    git clone https://github.com/tommy-muehle/puppet-typo3-testbox.git

    git submodule update --init --recursive

    vagrant up

## Customize
To customize the testbox, you can edit the custom typo3 module or modify the default manifest.

## Notices
You need a host entry in your host file (for example /etc/hosts) like this

    192.168.33.200 test.typo3.local
to see the result.
