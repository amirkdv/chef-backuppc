## Cookbook:: backuppc
## Recipe::   server

include_recipe 'apt'

user node['backuppc']['user']['username'] do
  home node['backuppc']['user']['home']
  #password node['backuppc']['user']['password']
  shell node['backuppc']['user']['shell']
end

directory node['backuppc']['user']['home'] do
  owner node['backuppc']['user']['username']
  group node['apache']['group']
  recursive true
end

include_recipe 'apache2'

# add backuppc user to apache's user group
group node['apache']['group'] do
  action :modify
  members node['backuppc']['user']['username']
  append true
end

package 'backuppc' 

bash 'suppress-qw-warnings' do
  code <<-EOH
    grep -ril 'qw(' #{node['backuppc']['install_dir']}/lib/BackupPC/ | while read file; 
    do sed -i "1i no warnings 'deprecated';" $file; done
  EOH
#TODO only_if?
end

web_user = node['backuppc']['web_user']
web_pass = node['backuppc']['web_pass']
# use md5 (via -1)
encrypt_cmd = "echo \"#{web_user}:$(openssl passwd -1 #{web_pass})\""

file "#{node['backuppc']['conf_dir']}/htpasswd" do
  owner node['backuppc']['user']['username']
  group node['apache']['group']
  content Mixlib::ShellOut.new(encrypt_cmd).run_command.stdout.strip + "\n"
end

web_app 'backuppc' do
  template "backuppc_vhost.conf.erb"
  notifies :restart, "service[apache2]"
end

link "#{node['apache']['dir']}/conf.d/backuppc.conf" do
  to "#{node['backuppc']['conf_dir']}/apache.conf"
end

key_file = "#{node['backuppc']['user']['home']}/.ssh/id_rsa"
execute 'generate-ssh-keys' do
  user node['backuppc']['user']['username']
  command "ssh-keygen -t rsa -f #{key_file} -N ''"
  creates key_file
end

package 'perltidy'
template '/usr/local/bin/bkpc' do
  source 'bkpc.erb'
  mode 0755
end
