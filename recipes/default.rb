#
# Cookbook Name:: batch-packages
# Recipe:: default
#
# Copyright 2012, AT&T Foundry
#
# All rights reserved 

# get list of available package collections
bags = data_bag("batch-packages")

# get list of roles applied to this node
roles = node['roles'].dup
# add the 'base' role that all nodes receive
roles.insert(0, "base")

# get the intersection of roles and available package collections
needed = roles & bags
Chef::Log.info "Installing packages: #{needed}"

# install packages for each collection
needed.each do |role|
  pkglist = search("batch-packages", "id:#{role}").first
  if pkglist then
    pkglist['packages'].each do |p, v|
      Chef::Log.info "Installing package #{p}..."
      if v then
        package p do
          version v
          action :install
        end
      else
        package p do
          action :install
        end
      end
    end
  end
end
