#!/bin/sh

. ./2-Config/*

action='UNK'

run_instance=$(date +%Y%m%d)_$(date +%s)
script_location=$(pwd)
deploy_scripts_location=$script_location/1-Binaries/1.1-DEPLOY
rollback_scripts_location=$script_location/1-Binaries/1.2-ROLLBACK
verify_scripts_location=$script_location/1-Binaries/1.3-VERIFY
log_folder_location=$script_location/3-Logs
instance_logs=$log_folder_location/$run_instance
mkdir -p $instance_logs

log_export_location="NA"

# -----------------------------------------------------------------------------------------------------------
# Aux Functions
# -----------------------------------------------------------------------------------------------------------
move_sqlplus_logs()
{
  case $action in
    DEPLOY)   mv $deploy_scripts_location/*.$spool_log_file_extension $instance_logs
    ;;
    ROLLBACK) mv $rollback_scripts_location/*.$spool_log_file_extension $instance_logs
    ;;
    VERIFY)   mv $verify_scripts_location/*.$spool_log_file_extension $instance_logs
    ;;
  esac
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
  log "[$(date +%c)] - [INFO] -  $@"
}

log_error()
{
  log "[$(date +%c)] - [ERROR] - $@"
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

log_outcome()
{
  log_separated "Resultado : $outcome."
  log_focused "Script Finalizado. Logs generados en $instance_logs."
}

set_outcome()
{
  outcome=$1
}

validate_action_parameter()
{
  if
     [ $action != "VERIFY" ] &&
     [ $action != "DEPLOY" ] &&
     [ $action != "ROLLBACK" ]
    then
      log_focused "Invalid option on -A parameter. Must select one of the following : VERIFY, DEPLOY, ROLLBACK."
      exit
  fi
}

run_action_script()
{
  log_focused "Ejecutando $action."
  log_separated "Conexion configurada como $sqlplus_connection."

  local script_path=""
  local script_filename="SQL_$action.sql"

  case $action in
    DEPLOY)   script_path=$deploy_scripts_location
    ;;
    ROLLBACK) script_path=$rollback_scripts_location
    ;;
    VERIFY)   script_path=$verify_scripts_location
    ;;
  esac

  cd $script_path

  if [ ! -f $script_filename ];
    then
      log_error "Script $script_path/$script_filename Not Found."
      set_outcome ERROR
    else
      sqlplus_log=$(sqlplus $sqlplus_connection @SQL_$action.sql)
      log_standard "Ejecución por SQLPlus : $sqlplus_log"
      move_sqlplus_logs
  fi

  cd $script_location
}

verify_action_outcome()
{
  outcome=$(cat "$instance_logs/SQL_$action""_LOG.log" | grep -o "@SUCCESS")

  if [ -z $outcome ]
    then
      outcome='@ERROR'
  fi
}

init_sqlplus_connection()
{
  sqlplus_connection="$db_user/$db_pass@$db_host:$db_port/$db_sid"
}

# -----------------------------------------------------------------------------------------------------------

## ----> Execution Script ----->

## Processing User Parameters
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
    A) action="$OPTARG"; validate_action_parameter;
    ;;
    e) log_export_location="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

init_sqlplus_connection   # 1 - Initiate SQLPlus
run_action_script         # 2 - Execute correlated script.
verify_action_outcome
log_outcome               # 3 - Log script outcome
export_logs               # 4 - Export generated logs
