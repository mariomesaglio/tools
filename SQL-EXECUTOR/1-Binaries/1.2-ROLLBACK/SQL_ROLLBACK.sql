SPOOL SQL_RLLBCK_LOG.log
SET HEADING OFF
SET SERVEROUTPUT ON
WHENEVER SQLERROR EXIT FAILURE

@./DROP_SR_DUMMY_PKG

DBMS_OUTPUT.PUT_LINE('___OK___');

SPOOL OFF;
EXIT;
/
