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

