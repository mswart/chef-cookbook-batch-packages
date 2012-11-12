Description
===========

The batch-packages cookbook facilitates the bulk installation of both gem and 
system packages. It should only be used for installation of dependencies that 
require little to no configuration. Such as development libraries.

Requirements
============

The batch-packages cookbook is a standalone cookbook, no dependencies.

Attributes
==========
None.

Usage
=====

To use the batch-packages cookbook, create a batch-packages data bag. For each
role you'd like to manage packages for, create a data bag item with the exact 
same id as the role. For example, if you have a roles/base.rb with id 'base' 
you'd create a data\_bags/batch-packages/base.json data bag item with id 'base'.

Populate the data bag with two hashes, 'packages' and 'gem\_packages'. Each hash 
item should have a key that's named for the package to install and a value of the
desired version of 'false' if the most current version is desired. 

Example:

    {
      "id": "base",
      "packages": {
        "python-software-properties": false,
        "openssl": "1.0.1",
        "libreadline6": false,
        "zlib1g": false,
        "sqlite3": false,
        "imagemagick": false,
        "unison": false,
        "zsh": false,
        "vim": false,
        "tree": false,
        "mosh" :false
      },
      "gem_packages": {
        "ruby-shadow": false
      }
    }
