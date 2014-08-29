archive_filename = File.basename node[:mongodb][:from_archive][:url]
remote_file "#{Chef::Config[:file_cache_path]}/#{archive_filename}" do
  source node[:mongodb][:from_archive][:url]
end

archive_basename = File.basename(archive_filename, '.*')
execute "file unzipping" do
  command "tar xf #{Chef::Config[:file_cache_path]}/#{archive_filename} -C #{node[:mongodb][:from_archive][:install_path]}"
  not_if "test -e #{node[:mongodb][:from_archive][:install_path]}/#{archive_basename}"
end

link "#{node[:mongodb][:from_archive][:install_path]}/mongodb" do
  to archive_basename
end

user node['mongodb']['user'] do
  system true
  shell "/bin/false"
end

directory node['mongodb']['config']['dbpath'] do
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
