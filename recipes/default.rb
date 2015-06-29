#
# Cookbook Name:: cloud9-core
# Recipe:: default
#
# Copyright (C) 2015 yusuke@newsdict.net
#
# All rights reserved - Do Not Redistribute
#
include_recipe 'nginx'

ppa "chris-lea/node.js"

node[:cloud9_core][:packages].each do |pkg|
  package pkg do
    action [:install]
  end
end
execute "update" do
  command "apt-get update -yq"
  user "root"
  group "root"
  action :run
end

with_home_for_user(node[:cloud9_core][:exec_user]) do
  git node[:cloud9_core][:install_dir] do
    repository node[:cloud9_core][:git_repository]
    revision node[:cloud9_core][:git_revision]
    action :sync
    user node[:cloud9_core][:exec_user]
    group node[:cloud9_core][:exec_user]
  end
end

execute "install cloud9 sdk" do
  not_if { File.exists?("/home/#{node[:cloud9_core][:exec_user]}/.c9") }
  command "cd #{node[:cloud9_core][:install_dir]}; scripts/install-sdk.sh;"
  user node[:cloud9_core][:exec_user]
  group node[:cloud9_core][:exec_user]
  action :run
end

template "/etc/init.d/cloud9" do
  source "init.d-cloud9.erb"
  mode '755'
end

service "cloud9" do
  supports :restart => true, :reload => true
  action [:enable, :start, :reload]
end

directory node[:cloud9_core][:workspace] do
  user node[:cloud9_core][:exec_user]
  group node[:cloud9_core][:exec_user]
  mode '0755'
  action :create
end

cookbook_file "server.crt" do
  path "/etc/nginx/server.crt"
  action :create
  user node['nginx']['user']
  group node['nginx']['group']
end

cookbook_file "server.key" do
  path "/etc/nginx/server.key"
  action :create
  user node['nginx']['user']
  group node['nginx']['group']
end

template "/etc/nginx/sites-available/cloud9" do
  source "cloud9"
  mode '755'
end

execute "Enable a config" do
  not_if { File.exists?("/etc/nginx/sites-enabled/cloud9") }
  command "#{node['nginx']['script_dir']}/nxensite cloud9"
  user 'root'
  group 'root'
  action :run
end

service 'nginx' do
  supports :status => true, :restart => true, :reload => true
  action   :reload
end