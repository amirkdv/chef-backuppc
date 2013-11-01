## Cookbook:: backuppc
## Attributes:: server
default['backuppc']['top_dir']      = '/var/lib/backuppc'
default['backuppc']['conf_dir']     = '/etc/backuppc'
default['backuppc']['install_dir']  = '/usr/share/backuppc'
default['backuppc']['cgi_dir']       = "#{node['backuppc']['install_dir']}/cgi-bin"

default['backuppc']['web_user']     = 'backuppc'
default['backuppc']['web_pass']     = 'backuppc'

default['backuppc']['user']['username']  = 'backuppc'
default['backuppc']['user']['home']     = '/var/lib/backuppc'
default['backuppc']['user']['password'] = 'backuppc'
default['backuppc']['user']['shell']    = '/bin/sh'

default['backuppc']['sendmail_relayhost'] = nil

force_override['apache']['user'] = node['backuppc']['user']['username']
