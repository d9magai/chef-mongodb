if node[:mongodb][:from_archive] then
  archive_filename = File.basename node[:mongodb][:from_archive][:url]
  remote_file "#{Chef::Config[:file_cache_path]}/#{archive_filename}" do
    source node[:mongodb][:from_archive][:url]
  end

  execute "file unzipping" do
    command "tar xf #{Chef::Config[:file_cache_path]}/#{archive_filename} -C #{node[:mongodb][:from_archive][:install_path]}"
  end

  link "#{node[:mongodb][:from_archive][:install_path]}/mongodb" do
    to File.basename(archive_filename, '.*')
  end

  user node['mongodb']['user'] do
    supports :manage_home => false
    action   [:create]
  end

  directory "/var/lib/mongodb" do
    owner node['mongodb']['user']
    group node['mongodb']['user']
    mode "0755"
    action :create
  end

  directory "/var/run/mongo" do
    owner node['mongodb']['user']
    group node['mongodb']['user']
    mode "0755"
    action :create
  end
else
  # install the 10gen repo if necessary
  include_recipe 'mongodb::10gen_repo' if %w(10gen mongodb-org).include?(node['mongodb']['install_method'])

  case node['platform_family']
  when 'debian'
    # this options lets us bypass complaint of pre-existing init file
    # necessary until upstream fixes ENABLE_MONGOD/DB flag
    packager_opts = '-o Dpkg::Options::="--force-confold" --force-yes'
  when 'rhel'
    # Add --nogpgcheck option when package is signed
    # see: https://jira.mongodb.org/browse/SERVER-8770
    packager_opts = '--nogpgcheck'
  else
    packager_opts = ''
  end

  # install
  package node[:mongodb][:package_name] do
    options packager_opts
    action :install
    version node[:mongodb][:package_version]
  end
end
