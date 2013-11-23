--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: usage_assm.sql 30 2010-01-12 20:58:11Z oracle $
--
-- Detailinformation for an assm-Segment
--
-- Parameter 1: Owner
-- Parameter 2: Segment-Name
-- Parameter 3: Segment-Type
-- Parameter 4: PARTITION_NAME

variable unformatted_blocks number; 
variable unformatted_bytes number; 
variable fs0025blocks number; 
variable fs0025bytes number; 
variable fs2550blocks number; 
variable fs2550bytes number; 
variable fs5075blocks number; 
variable fs5075bytes number; 
variable fs75100blocks number; 
variable fs75100bytes number; 
variable full number; 
variable fullb number; 

begin 
dbms_space.space_usage('&1','&2', 
                        '&3', 
                        :unformatted_blocks, :unformatted_bytes, 
                        :fs0025blocks, :fs0025bytes, 
                        :fs2550blocks, :fs2550bytes, 
                        :fs5075blocks, :fs5075bytes, 
                        :fs75100blocks, :fs75100bytes, 
                        :full, :fullb); 
end; 
/ 

set lines 120 pages 100

column "unf_MB" format 9,999,999.999
column "0025_MB" format 9,999,999.999
column "2550_MB" format 9,999,999.999
column "5075_MB" format 9,999,999.999
column "75100_MB" format 9,999,999.999
column "full_MB" format 9,999,999.999

PROMP Blocks

select :unformatted_blocks 
      ,:fs0025blocks
      ,:fs2550blocks
      ,:fs5075blocks
      ,:fs75100blocks
      ,:full
from dual;

PROMPT Bytes

select :unformatted_bytes/1024 unf_MB
      ,:fs0025bytes/1024/1024 "0025_MB"
      ,:fs2550bytes/1024/1024 "2550_MB"
      ,:fs5075bytes/1024/1024 "5075_MB"
      ,:fs75100bytes/1024/1024 "75100_MB"
      ,:fullb/1024/1024 "full_MB"
from dual;
