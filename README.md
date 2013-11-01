## BackupPC cookbook
#### Description
Installs and configures a BackupPC server and spins up its web GUI through
Apache.
#### Usage
You can grab the cookbook from `./cookbooks/backuppc` and use it as you wish or
use the helper scripts (that install system requirements, including Chef, if
necessary, before provisioning the machine):

```bash
./bootstrap.sh -j backuppc-server.json

# on subsequent Chef runs, if you want to avoid package installations
./bootstrap.sh -j backuppc-server.json -n
````
