## Cookbook:: backuppc
## Attributes:: server
include_attribute 'apache2::default'

default['backuppc']['top_dir']      = '/var/lib/backuppc'
default['backuppc']['conf_dir']     = '/etc/backuppc'
default['backuppc']['install_dir']  = '/usr/share/backuppc'
default['backuppc']['cgi_dir']       = "#{node['backuppc']['install_dir']}/cgi-bin"

default['backuppc']['web_user']     = 'backuppc'
default['backuppc']['web_pass']     = 'backuppc'

default['backuppc']['user']         = 'backuppc'
default['backuppc']['group']        = node['apache']['group']

default['backuppc']['sendmail_relayhost'] = nil
force_override['apache']['user'] = node['backuppc']['user']['username']
