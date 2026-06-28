#!/bin/bash
############################################
##          H.ESMAEILI 20260601           ##
############################################

export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=$ORACLE_BASE/product/11.2.0/db
export ORACLE_SID=DOP2
export PATH=$PATH:$ORACLE_HOME/bin:/usr/sbin
export LD_LIBRARY_PATH=$ORACLE_HOME/lib
export NLS_LANG=AMERICAN_AMERICA.AR8MSWIN1256
#export TNS_ADMIN=/u01/app/oracle/product/19c/db/network/admin
export LD_LIBRARY_PATH=$ORACLE_HOME/lib

#######################################################

DATE=$(date +"%Y%m%d_%H%M%S")
HOST=$(hostname)
REPORT="/tmp/rac_healthcheck_${HOST}_${DATE}.log"

exec > >(tee -a ${REPORT}) 2>&1

echo "===================================================="
echo "    ORACLE RAC AUTO DISCOVERY FULL HEALTH CHECK     "
echo "===================================================="

echo "Hostname : $HOST"
echo "Date     : $(date)"
echo "Report   : $REPORT"
echo "===================================================="

GRID_USER=grid
ORACLE_USER=oracle

BLINK='\033[5m'
GREEN='\033[1;32m'
NC='\033[0m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
BLUE='\033[1;34m'

echo "###################################################"
echo " 1. DETECTING RAC NODES                            "
echo "###################################################"

NODE_LIST=$(su - ${GRID_USER} -c "olsnodes" 2>/dev/null)

if [ -z "$NODE_LIST" ]; then
echo -e "${RED}ERROR: Unable ro detect RAC nodes.${NC}"
exit 1
fi

NODE_COUNT=$(echo "$NODE_LIST" | wc -l)
echo -e "${GREEN} Detected RAC Nodes:${NC}"
echo "$NODE_LIST"
echo
echo -e "${BLUE} Total Nodes Detected $NODE_COUNT${NC}"

echo
echo "###################################################"
echo " 2. CLUSTER STATUS                                 "
echo "###################################################"

echo -e "${YELLOW} CRS STATUS${NC}"
su - ${GRID_USER} -c "crsctl check cluster -all"
echo
echo -e "${YELLOW}CLUSTER RESOURCES${NC}"
su - ${GRID_USER} -c "crsctl stat res -t"
echo
echo -e "${YELLOW}NODE STATUS${NC}"
su - ${GRID_USER} -c "olsnodes -n"
echo
su - ${GRID_USER} -c "olsnodes -s"

echo
echo "###################################################"
echo " 3. NETWORK CHECK                                  "
echo "###################################################"

for NODE in $NODE_LIST
do
echo
echo -e "${BLUE}PING TEST : $NODE${NC}"
ping -c 2 $NODE
done

echo
echo "###################################################"
echo " 4. ASM STATUS                                     "
echo "###################################################"

ASM_INSTANCE=$(ps -ef |grep pmon |grep ASM| grep -v grep |head -1 |awk -F_ '{print $3}')
su - ${GRID_USER} -c "export ORACLE_SID=${ASM_INSTANCE}
sqlplus -s / as sysasm <<'EOF'

set line 220
col name format a20
col state format a12
col type format a10
col path format a50

prompt ==========ASM DISKGROUPS===========

select 
name,
state,
type,
total_mb,
free_mb 
from v\$asm_diskgroup;

prompt ==========ASM DISKS============

select 
group_number,
disk_number,
name,
path,
state,
header_status 
from v\$asm_disk;
exit;
EOF
"

echo
echo "###################################################"
echo " 5. DATABASE DISCOVERY                             "
echo "###################################################"

BDLIST=$(ps -ef |grep pmon |grep -v ASM|grep -v grep |awk -F_ '{print $3}' |sed 's/[0-9]*$//' |sort -u)

if [ -z "$DBLIST" ];then
   echo -e "${RED} No RAC databases found.${NC}"
else
   echo -e "${GREEN}Detected Databases:{NC}"
   ehco "$DBLIST"
fi

echo
echo "###################################################"
echo " 6. DATABASE HEALTH CHECK                          "
echo "###################################################"

for DB in $DBLIST
do

echo
echo "=================================================="
echo "DATABASE : $DB"
echo "=================================================="

FIRST_INSTANCE=$(srvctl status database -d $DB 2>/dev/null |head -1 |awk '{print $2}')
su - ${ORACLE_USER} -c"
export ORACLE_SID=${FIRST_INSTANCE}
sqlplus -s / as sysdba <<'EOF'

set lines 220
col instance_name format a15
col host_name format a25
col status format a12

prompt ======== INSTANCE STATUS ==========

select
inst_id,
instance_name,
host_name,
status,
database_status
from gv\$instance;

prompt ======== DATABASE STATUS ==========

select
name,
open_mode,
database_role,
log_mode,
flashback_on
from v\$database;

prompt ======== TABLESPACE USAGE ==========

select
tablespace_name,
round((used_space/tablespace_size)*100,2) pct_used
from dba_tablespace_usage_metrics
order by 2 desc;

prompt ======== INVALID OBJECTS ==========

select
owner,
count(*) invalid_count
from dba_objects
where status='INVALID'
group by owner;

prompt ======== BLOCKING SESSIONS ==========

select inst_id,
sid,
serial#,
blocking_session
from gv\$session
where blocking_session is not null;

prompt ======== ARCHIVE DEST STATUS ==========

select
dest_name,
status,
error
from v\$archive_dest
where status <> 'INACTIVE';

prompt ======== FRA USAGE ==========

select
name,
round(space_limit/1024/1024) MB_LIMIT,
round(space_used/1024/1024) MB_USED
from v\$recovery_file_dest;

exit;
EOF
"
done

echo
echo "###################################################"
echo " 7. RAC SERVICES STATUS                            "
echo "###################################################"

for DB in $DBLIST
do

echo
echo "=================================================="
echo "DATABASE SERVICES : $DB"
echo "=================================================="

echo
echo -e "${YELLOW} SRVCTL SERVICE STATUS${NC}"
srvctl status service -d $DB

echo
echo -e "${YELLOW} SERVICE CONFIGURATION${NC}"
srvctl config service -d $DB

FIRST_INSTANCE=$(srvctl status database -d $DB 2>/dev/null |head -1| awk '{print $2}')

su - ${ORACLE_USER} -c "export ORACLE_SID=${FIRST_INSTANCE}

sqlplus -s / as sysdba <<'EOF'

set line 220
col name format a30
col network_name format a40
col pdb format a20

prompt ======== REGISTERED SERVICES  ==========

select
name,
network_name,
pdb
from dba_services
order by name;

prompt ======== ACTIVE SERVICES ==========

sekect 
inst_id,
name,
network_name
from gv\$active_services
order by inst_id,name;

prompt ======== SERVICE FAILOVER ==========

select
name,
failover_method,
failover_type,
failover_retries,
failover_delay
from dba_services
order by name;

prompt ======== SERVICE SUMMARY ==========

select
inst_id,
name
from gv\$services
order by inst_id,name;

exit;
EOF
"

done

echo
echo "###################################################"
echo " 8. LISTENER STATUS                                "
echo "###################################################"


su - ${GRID_USER} -c "srvctl status listener"
echo
su - ${GRID_USER} -c "lsnrctl status"

echo
echo "###################################################"
echo " 9. OCR / VOTING DISK                              "
echo "###################################################"

su - ${GRID_USER} -c "ocrcheck"
echo
su - ${GRID_USER} -c "crsctl query css votedisk"
echo
su - ${GRID_USER} -c "ocrconfig -showbackup"

echo
echo "###################################################"
echo " 10. OS PERFORMANCE                                "
echo "###################################################"


echo
echo -e "${YELLOW}CPU / LOAD${NC}"
uptime

echo
echo -e "${YELLOW}TOP PROCESSES${NC}"
top -b -n 1 |head -20

echo
echo -e "${YELLOW}MEMORY${NC}"
free -g

echo
echo -e "${YELLOW}IOSTAT${NC}"
iostat -xm 2 2

echo
echo -e "${YELLOW}VMSTAT${NC}"
vmstat 2 5

echo
echo "###################################################"
echo " 11.ALERT LOG ERRORS                               "
echo "###################################################"

find $ORACLE_BASE/diag -name "alert*.log" 2>/dev/null |while read LOG
do

echo
echo -e "${BLUE}Checking : $LOG${NC}"
grep -iE "ORA-|ERROR|FAILED|WARNING" $LOG |tail -20
done

echo
echo "###################################################"
echo " 12.FINAL SUMMARY                                  "
echo "###################################################"

echo
echo -e "${GREEN}Detected Nodes : $NODE_COUNT${NC}"

echo
echo -e "${GREEN}Detected Database :${NC}"
echo "$DBLIST"


echo
echo -e "${GREEN}Health Check Report : ${NC}"
echo "$REPORT"

echo
echo -e "${BLINK}${GREEN} RAC HEALTH CHECK COMPLETED SUCCESSFULLY:)${NC}"
