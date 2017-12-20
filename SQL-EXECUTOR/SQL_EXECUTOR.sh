#!/bin/sh

. ./2-Config/*

action='UNK'

run_instance=$(date +%Y%m%d)_$(date +%s)
script_location=$(pwd)
deploy_scripts_location=$script_location/1-Binaries/1.1-DEPLOY
rllbck_scripts_location=$script_location/1-Binaries/1.2-RLLBCK
log_folder_location=$script_location/$log_folder_name
instance_logs=$log_folder_location/$run_instance
mkdir -p $instance_logs

log_export_location="NA"

move_sqlplus_logs()
{
  if [ $action == 'DEPLOY' ]
    then
      mv $deploy_scripts_location/*.$spool_log_file_extension $instance_logs
  fi

  if [ $action == 'ROLLBACK' ]
    then
      mv $rllbck_scripts_location/*.$spool_log_file_extension $instance_logs
  fi
}

export_logs()
{
  if [ $log_export_location != "NA" ]
    then
      mv $instance_logs $log_export_location
      instance_logs=$log_export_location
  fi
}

log()
{
  echo $@
  echo $@ >> $instance_logs/SQL_EXECUTOR_LOG.log
}

log_standard()
{
  log "[$(date +%s)] - $@."
}

log_separator()
{
  log "-----------------------------------------------------------------------------"
}

log_focused()
{
  log_separator
  log_standard $@
  log_separator
}

log_separated()
{
  log
  log_standard $@
  log
}


if [ $# -eq 0 ]
  then
    db_user=$default_db_user
    db_pass=$default_db_pass
    db_host=$default_db_host
    db_port=$default_db_port
    db_sid=$default_db_sid
  else
    while getopts ":u:l:h:p:s:A:e:" opt; do
      case $opt in
        u) db_user="$OPTARG"
        ;;
        l) db_pass="$OPTARG"
        ;;
        h) db_host="$OPTARG"
        ;;
        p) db_port="$OPTARG"
        ;;
        s) db_sid="$OPTARG"
        ;;
        A) action="$OPTARG"
        ;;
        e) log_export_location="$OPTARG"
        ;;
        \?) echo "Invalid option -$OPTARG" >&2
        ;;
      esac
    done
fi

if
   [ $action != "VERIFY" ] &&
   [ $action != "DEPLOY" ] &&
   [ $action != "ROLLBACK" ]
  then
    log_focused "Invalid option on -A parameter. Must select one of the following : VERIFY, DEPLOY, ROLLBACK"
    exit
fi

sqlplus_connection="$db_user/$db_pass@$db_host:$db_port/$db_sid"

log_focused "Ejecutando $action"
log_separated "Conexion configurada como $sqlplus_connection"

case $action in
    "VERIFY")
      echo "Esto es un STUB, deberia incluirse la lógica necesaria." # Esto es un STUB, deberia incluirse la lógica necesaria.
      break
      ;;
    "DEPLOY")
      cd $deploy_scripts_location
      sqlplus_log=$(sqlplus $sqlplus_connection @SQL_DEPLOY.sql)
      log_standard "Ejecución por SQLPlus : $sqlplus_log"
      move_sqlplus_logs
      break
      ;;
    "ROLLBACK")
      cd $rllbck_scripts_location
      sqlplus_log=$(sqlplus $sqlplus_connection @SQL_RLLBCK.sql)
      log_standard "Ejecución por SQLPlus : $sqlplus_log"
      move_sqlplus_logs
      break
      ;;
    *) echo invalid option;;
  esac

  export_logs

  log_separated "Resultado : $outcome."
  log_focused "Script Finalizado. Logs generados en $instance_logs"
