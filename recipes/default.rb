#
# Cookbook Name:: batch-packages
# Recipe:: default
#
# Copyright 2012, AT&T Foundry
#
# All rights reserved


# get list of available package collections - silently returns empty list if data_bag not found
bags = data_bag node['batch-packages']['data_bag']

# get list of roles applied to this node
roles = node['roles'].dup
# add the 'base' role that all nodes receive
roles.insert(0, "base")

# get the intersection of roles and available package collections
needed = roles & bags
Chef::Log.info "Receive packages for roles: #{needed.inspect} + attributes"

# fetch + merge package lists
packages = {}
gem_packages = {}
needed.each do |role|
  item = data_bag_item(node['batch-packages']['data_bag'], role)
  packages.merge!(item['packages'] || {})
  gem_packages.merge!(item['gem_packages'] || {})
end
packages.merge! node['batch-packages']['packages']
gem_packages.merge! node['batch-packages']['gem_packages']

# create resource definitions (for packages and for gem_packages)
# this is a little bit ruby magic to avoid code dublication
{
  lambda { |n, &block| package n, &block } => ['system', packages],
  lambda { |n, &block| gem_package n, &block } => ['ruby', gem_packages]
}.each do |define_resource, (pkg_type, pkgs)|
  # install packages
  pkgs.each do |pkg, ver|
    next if ver.nil? # skip
    define_resource.call pkg do
      case ver
        when false then
          Chef::Log.info "Removing #{pkg_type} package #{pkg}..."
          action :remove
        when true then
          Chef::Log.info "Upgrading #{pkg_type} package #{pkg}..."
          action :upgrade
        when -1 then
          Chef::Log.info "Purging #{pkg_type} package #{pkg}..."
          action :purge
        when '' then
          Chef::Log.info "Installing #{pkg_type} package #{pkg}..."
          action :install
        else
          Chef::Log.info "Installing #{pkg_type} package #{pkg}=#{ver}..."
          action :install
          version ver
      end
    end
  end
end
