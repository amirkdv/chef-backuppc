#! /bin/bash
set -e
repo_dir="$( cd "$( dirname "$0" )" && pwd )"
. $repo_dir/helpers.sh
options=('-r', '--run-list', '--json-file', '-j', '--why-run', '-w', '--why-run', '--no-deps','-n', '-g', '--generate-only')
# argument parser:
while (( "$#" )); do
  if [[ $1 == "--run-list" || $1 == "-r" ]]; then
    # do not allow multiple -r options
    [[ ${#run_list[@]} -gt 0 ]] && usage
    shift
    until [[ ${options[*]} =~ $1 ]]; do
      # TODO ${options[*]} =~ $1 is clearly prone to corner-case errors
      # shift until you get to the next argument
      run_list[$[${#run_list[@]}]]=$1
      shift
    done
    continue
  elif [[ $1 == "--json-file" || $1 == "-j" ]]; then
    [[ ! -z $json_path ]] && usage # do not allow multiple -j options
    shift
    [[ -z $1 ]] && usage # require an argument to -j 
    json_path=$1
    # do not allow multiple arguments to -j
    [[ ! -z $2 ]] && [[ ! ${options[*]} =~ $2 ]] && usage
  elif [[ $1 == "--why-run" || $1 == "-w" ]]; then
    [[ ! -z $why_run ]] && usage # do not allow multiple -w options
    why_run=1
  elif [[ $1 == "--no-deps" || $1 == "-n" ]]; then
    [[ ! -z $no_deps ]]  && usage # do not allow multiple -n options
    no_deps=1
  elif [[ $1 == "--generate-only" || $1 == "-g" ]]; then
    [[ ! -z $generate_only ]] && usage # do now allow multiple -g options
    generate_only=1
  fi
  shift
done
[[ -z $run_list ]] && [[ -z $json_path ]] && usage
if [[ ! -z $generate_only ]]; then
  [[ -z $run_list ]] && [[ -z $json_path ]] && usage
  generate_files
  exit 0
fi
[[ ! -z $json_path ]] && [[ $json_path != /* ]] && json_path="$repo_dir/$json_path"
[[ -z $no_deps ]] && install_deps
setup_known_hosts
generate_files
chef_provision
