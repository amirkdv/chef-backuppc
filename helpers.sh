#! /bin/bash
# helper functions for bootstrap.sh
function print_err() {
  tput setaf 1; echo -e "bootstrap.sh:\t$1";  tput sgr0
}
function print_log() {
  tput setaf 2;  echo -e "bootstrap.sh:\t$1 ..."; tput sgr0
}
function usage() {
  print_err "Wrong argument format."
  echo -e "Options:\n"
  echo -e "\t -r, [--run-list]\trun chef-solo with the specified run lisst. For example,"
  echo -e "\t\t\t\tbootstrap.sh -r first second"
  echo -e "\t\t\t\twill run chef-solo with \"run_list\":[\"first\",\"seocnd\"]"
  echo -e "\t -j, [--json-file]\tuse the next argument as --json-attribs argument to chef-solo, the next argument must be an absolute path"
  echo -e "\t -w, [--why-run]\trun chef-solo with option: --why-run"
  echo -e "\t -n, [--no-deps]\tdo not install package and gem dependencies"
  echo -e "\t -g, [--generate-only]\tonly generate solo.rb and dna.json files, do not run or install any software"
  exit 1
}

function install_deps(){
  print_log "installing dependencies"
  apt-get update
  apt-get install -y git curl ack-grep vim
  apt-get install -y ruby1.9.1 ruby1.9.1-dev build-essential libxml2-dev libxslt-dev
  gem install chef --version '>11.0.0' --no-rdoc --no-ri
  gem install berkshelf rake foodcritic --no-rdoc --no-ri
}

function setup_known_hosts(){
  print_log "setting up known hosts"
  mkdir -p ~/.ssh
  touch ~/.ssh/known_hosts
  declare -a hosts=(git.ewdev.ca github.com)
  for i in ${hosts[@]}
  do
    ssh-keygen -R $i
    ssh-keyscan $i >> ~/.ssh/known_hosts
  done
}

function generate_files(){
  print_log "generating Chef configuration file at $repo_dir/solo.bootstrap.rb"
  cat > $repo_dir/solo.bootstrap.rb <<-EOF
file_cache_path "/tmp/chef-solo"
role_path "$repo_dir/roles"
solo true
verbose_logging true
cookbook_path [ "$repo_dir/cookbooks" , "$repo_dir/berks-cookbooks" ]
log_level :debug
EOF
  # generate dna.json
  [[ ! -z $json_path ]] && return
  json_path="$repo_dir/dna.bootstrap.json"
  print_log "generating json attributes file at $json_path"
  echo -e "{\n\t\"run_list\" : [" > $json_path
  length=$((${#run_list[@]} - 2))
  for (( i=0; i<=$length; i++ ))
  do
    echo -e "\t\t\"${run_list[$i]}\"," >> $json_path
  done
  echo -e "\t\t\"${run_list[$i]}\"\n\t]\n}\n" >> $json_path
}

function chef_provision(){
  print_log "updating cookbooks"
  # as long as this issue is not resolved
  # https://github.com/RiotGames/berkshelf/issues/220
  # blow away berkshelf's cached info
  rm -rf ~/.berkshelf
  #berks update  --berksfile $repo_dir/Berksfile
  berks install --berksfile $repo_dir/Berksfile --path $repo_dir/berks-cookbooks
  [[ ! -z $why_run ]] && why_run="--why-run"
  print_log "starting provisioning";
  print_log "running chef-solo -c $repo_dir/solo.bootstrap.rb -j $json_path $why_run"
  chef-solo -c $repo_dir/solo.bootstrap.rb -j $json_path $why_run
}
