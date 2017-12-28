#!/bin/sh

git_user=$1
git_password=$2
git_repo=$3
sql_package_path=$4

log_folder=${11}
mkdir -p log_folder

log()
{
  echo $@
  echo $@ >> $log_folder/SQL_DeployMachine.log
}

clear
log "-----------------------------------------------------------------------------"
log "[$(date +%c)] - Realizando Checkout desde : "$git_repo
git clone "https://"$git_user":"$git_password"@bitbucket.org/"$git_repo".git"

cd ${git_repo##*/}/$sql_package_path

chmod +x ./*

./SQL_EXECUTOR.sh -u $5 -l $6 -h $7 -p $8 -s $9 -A ${10} -e ${11}
log "[$(date +%c)] - Ejecucion Finalizada. Logs generados en  : "$log_folder
log "-----------------------------------------------------------------------------"
log
