#
# Cookbook Name:: cloud9-core
# Recipe:: default
#
# Copyright (C) 2015 yusuke@newsdict.net
#
# All rights reserved - Do Not Redistribute
#
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
