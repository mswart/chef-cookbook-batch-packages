Description
===========
[![Build Status](https://travis-ci.org/mswart/chef-cookbook-batch-packages.png)](https://travis-ci.org/mswart/chef-cookbook-batch-packages)

The batch-packages cookbook facilitates the bulk installation of both gem and
system packages. It should only be used for installation of dependencies that
require little to no configuration. Such as development libraries.

The packages which should be installed can be passed in via attributes or data
bag item for every role.

Requirements
============

The batch-packages cookbook is a standalone cookbook, no dependencies.

Attributes
==========

There are only a few options:

* `node['batch-packages']['data_bag']` (`batch-packages`): Which data bag should
  be used to receive package list? This data bag must not exists.
* `node['batch-packages']['packages']` (`{}`): List of system packages
  which should be installed. Information about the [package definition format](#package-definition)
* `node['batch-packages']['gem_packages']` (`{}`):  List of ruby packages
  which should be installed. Information about the [package definition format](#package-definition)


Package definition
==================

`packages` and `gem_packages` are hashes/dictionariese and defining which
packages should be managed.

The key is the package name (e.g. openssl or ruby-shadow).

The value should be ...

* `''`: to install this package
* `true`: to upgrade the newest version
* a `String`: to install is special version
* `false`: to remove this package
* `-1`: to purge this packages, normally means uninstall package and remove
  configuration files
* `nil`: to not manage this package (used to remove previous defined action)

See [the official documentation about package resources](http://docs.opscode.com/chef/resources.html#package)
for a deeper understanding what this actions mean. All tasks are delegated
to the package/gem_package resource.

Usage
=====

With data bages
---------------

To use the batch-packages cookbook, create a batch-packages data bag. For each
role you'd like to manage packages for, create a data bag item with the exact
same id as the role. For example, if you have a roles/base.rb with id 'base'
you'd create a data\_bags/batch-packages/base.json data bag item with id 'base'.

Populate the data bag with two hashes, 'packages' and 'gem\_packages'. Each hash
item should have a key that's named for the package to install and a value that
define which action should be done (true for normale install). See
[package definition format](#package-definition) for all possible values.

Example:

```json
{
  "id": "base",
  "packages": {
    "python-software-properties": true,
    "openssl": "1.0.1",
    "libreadline6": true,
    "zlib1g": true,
    "sqlite3": true,
    "imagemagick": true,
    "unison": true,
    "zsh": true,
    "vim": true,
    "tree": true,
    "mosh": true
  },
  "gem_packages": {
    "ruby-shadow": true
  }
}
```

Overwrite previous definition
-----------------------------

The cookbooks receives the package information from all roles which have a data
bag entry (in run_list order) and at last the package information from the node
attributes. So you can overwrite rules.

The base role:

```json
{
  "id": "base",
  "packages": {
    "openssl": "1.0.1",
    "zsh": true,
    "vim": true,
  }
}
```

and the node `special` attributes:

```json
{
  "batch-packages": {
    "packages": {
      "openssl": null,
      "zsh": false,
    }
  }
}
```

This installes openssl version 1.0.1, zsh and vim on all nodes but on the node
`special` openssl is not installed via chef (but also not removed), `zsh` is
removed but all other packages (here vim) is installed like on all other nodes.
