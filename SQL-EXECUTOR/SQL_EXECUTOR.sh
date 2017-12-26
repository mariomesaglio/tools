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
# Auxiliary Functions
# -----------------------------------------------------------------------------------------------------------
move_sqlplus_logs()
{
   mv $1/*.log $instance_logs
}

log()
{
  echo $@
  echo $@ >> $instance_logs/SQL_EXECUTOR_LOG.log
}

log_standard()
{
  log "[$(date +%c)] - [INFO] - $@"
}

log_error()
{
  log "[$(date +%c)] - [ERROR] -$@"
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
  log_separated "Resultado - "$action" : $outcome."
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

execute_script()
{
  local prev_location=$(pwd)

  cd $1

  if [ ! -f "$2" ];
    then
      log_error "Script $1/$2 Not Found."
      set_outcome ERROR
    else
      sqlplus_log=$(sqlplus $sqlplus_connection @$2)
      log_standard "Ejecución por SQLPlus : $sqlplus_log"
      move_sqlplus_logs $1
  fi

  cd $prev_location
}


# -----------------------------------------------------------------------------------------------------------
# Core Functions
# -----------------------------------------------------------------------------------------------------------
run_action_script()
{
  log_separated "Ejecutando $action."

  local action_script_location=''
  local action_script_name="SQL_$action.sql"

  case $action in
    DEPLOY)   action_script_location=$deploy_scripts_location
    ;;
    ROLLBACK) action_script_location=$rollback_scripts_location
    ;;
    VERIFY)   action_script_location=$verify_scripts_location
    ;;
  esac

  execute_script $action_script_location $action_script_name
}

verify_action_outcome()
{
  outcome=$(cat "$instance_logs/SQL_$action""_LOG.log" | grep -o "@SUCCESS")

  if [ -z $outcome ]
    then
      outcome='@ERROR'
  fi

  case $action in
    DEPLOY)   log_outcome; action="VERIFY"; run_action_script; verify_action_outcome
    ;;
    ROLLBACK) log_outcome
    ;;
    VERIFY)   log_outcome
    ;;
  esac
}

init_sqlplus_connection()
{
  sqlplus_connection="$db_user/$db_pass@$db_host:$db_port/$db_sid"
  log_separated "Conexion configurada como $sqlplus_connection."
}

export_logs()
{
  if [ $log_export_location != "NA" ]
    then
      mv $instance_logs $log_export_location
      instance_logs=$log_export_location
  fi
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

init_sqlplus_connection   # 1 - Initiate SQLPlus Connection
run_action_script         # 2 - Execute correlated script.
verify_action_outcome     # 3 - Verify the script outcome.
export_logs               # 4 - Export generated logs

log_focused "Script Finalizado. Logs generados en $instance_logs."
