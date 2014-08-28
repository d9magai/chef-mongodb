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
