#!/bin/sh

git_user=$1
git_password=$2
git_repo=$3
mock_project_path=$4
mock_project_name=$5
mock_listen_port=$6
mock_service_name=$7

log()
{
  echo $@
  echo $@ >> $log_folder/ESB_Mock.log
}

clear
log "-----------------------------------------------------------------------------"
log "[$(date +%c)] - Realizando Checkout desde : "$git_repo
git clone "https://"$git_user":"$git_password"@bitbucket.org/"$git_repo".git"

cd ${git_repo##*/}/$mock_project_path

chmod +x ./*

mockservicerunner.sh -p $mock_listen_port -m $mock_service_name $mock_project_name &

tail -f /dev/null

log "[$(date +%c)] - Ejecucion Finalizada. Logs generados en  : "$log_folder
log "-----------------------------------------------------------------------------"
log
