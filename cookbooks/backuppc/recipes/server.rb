## Cookbook:: backuppc
## Recipe::   server

include_recipe 'apt'

include_recipe 'apache2'

# add backuppc user to apache's user group
group node['apache']['group'] do
  action :modify
  members node['backuppc']['user']['username']
  append true
end

package 'backuppc' 

append_code="no warnings 'deprecated';"
bash 'suppress-qw-warnings' do
  code <<-EOH
    grep -ril 'qw(' #{node['backuppc']['install_dir']}/lib/BackupPC/ | while read file; 
    do grep -q "#{append_code}" $file || sed -i "1i #{append_code}" $file; done
  EOH
end

web_user = node['backuppc']['web_user']
web_pass = node['backuppc']['web_pass']
encrypt_cmd = "echo \"#{web_user}:$(openssl passwd -1 #{web_pass})\""

file "#{node['backuppc']['conf_dir']}/htpasswd" do
  owner node['backuppc']['user']['username']
  group node['apache']['group']
  content Mixlib::ShellOut.new(encrypt_cmd).run_command.stdout.strip + "\n"
end

web_app 'backuppc' do
  template 'backuppc_vhost.conf.erb'
  notifies :restart, 'service[apache2]'
end

link "#{node['apache']['dir']}/conf.d/backuppc.conf" do
  to "#{node['backuppc']['conf_dir']}/apache.conf"
end

private_key = "#{node['backuppc']['user']['home']}/.ssh/id_rsa"
public_key = "#{private_key}.pub"
execute 'generate-ssh-keys' do
  user node['backuppc']['user']['username']
  command "ssh-keygen -t rsa -f #{private_key} -N ''"
  creates private_key
end

execute 'serve-public-key-for-clients' do
  user node['backuppc']['user']['username']
  group node['apache']['group']
  command "cp #{public_key} #{node['backuppc']['cgi_dir']}"
end
