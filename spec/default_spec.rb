require 'chefspec'

describe 'batch-packages::default' do
  let(:chef_runner) { ChefSpec::ChefRunner.new }
  let(:chef_run) { chef_runner.converge 'batch-packages::default' }
  let(:packages1) do
    { 'packages' => { 'vim' => true }, 'gem_packages' => { 'ruby-shadow' => true } }
  end

  let(:package_actions) do
    {
      'packages' => { 'vim' => true, 'git' => '', 'emacs' => -1, 'nano' => false,  },
      'gem_packages' => { 'ruby-shadow' => '', 'pg' => true, 'mysql' => false, 'sqlite' => -1 }
    }
  end

  let(:overwrite_actions) do
    {
      'packages' => { 'vim' => nil, 'git' => true },
      'gem_packages' => { 'ruby-shadow' => '', 'pg' => true, 'mysql' => false, 'sqlite' => -1 }
    }
  end

  before do
    Chef::Config[:role_path] = 'spec/support/roles'
    Chef::Config[:data_bag_path] = 'spec/support/data_bags'
  end

  context 'with batch-package data bag' do
    before do
      Chef::Recipe.any_instance.stub(:data_bag).with('batch-packages').and_return %w(base)
    end
    it 'should always use base role' do
      Chef::Recipe.any_instance.should_receive(:data_bag_item).with('batch-packages', 'base').and_return Hash.new
      chef_run
    end
    it 'should be able to install, upgrade, remove and purge packages' do
      Chef::Recipe.any_instance.should_receive(:data_bag_item).with('batch-packages', 'base').and_return package_actions
      chef_run.should install_package('git')
      chef_run.should upgrade_package('vim')
      chef_run.should remove_package('nano')
      chef_run.should purge_package('emacs')
    end

    it 'should be able to install, upgrade, remove and purge gem packages' do
      Chef::Recipe.any_instance.should_receive(:data_bag_item).with('batch-packages', 'base').and_return package_actions
      chef_run.should install_gem_package('ruby-shadow')
      chef_run.should upgrade_gem_package('pg')
      chef_run.should remove_gem_package('mysql')
      chef_run.should purge_gem_package('sqlite')
    end

    it 'should support overwritte settings in lower roles or node attributes' do
      Chef::Recipe.any_instance.stub(:data_bag).with('batch-packages').and_return %w(base overwrite)
      Chef::Recipe.any_instance.should_receive(:data_bag_item).with('batch-packages', 'base').and_return package_actions
      Chef::Recipe.any_instance.should_receive(:data_bag_item).with('batch-packages', 'overwrite').and_return overwrite_actions
      chef_runner.node.set['batch-packages']['packages']['nano'] = -1
      chef_run = chef_runner.converge 'role[overwrite]', 'batch-packages::default'
      chef_run.should_not install_package('vim')
      chef_run.should upgrade_package('git')
      chef_run.should purge_package('nano')
      chef_run.should purge_package('emacs')
    end
  end

  context 'without batch-package data bag' do
    it 'should log warning about missing data bag' do
      Chef::Log.should_receive(:info).with('Receive packages for roles: [] + attributes').once
      Chef::Log.should_receive(:info).with(any_args()).any_number_of_times
      chef_run
    end
  end
end
