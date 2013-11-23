--
-- Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
-- $Id: undostatall.sql 241 2010-11-14 11:42:54Z tbr $
--
-- Undostat-Information from V$undostat for
--

/*
BEGIN_TIME     - The beginning time for this interval check
END_TIME       - The ending time for this interval check
UNDOTSN        - The undo tablespace number
UNDOBLKS       - The total number undo blocks consumed during the time interval
TXNCOUNT       - The total number of transactions during the interval
MAXQUERYLEN    - The maximum duration of a query within the interval
MAXCONCURRENCY - The highest number of transactions during the interval
UNXPSTEALCNT   - The number of attempts when unexpired blocks were stolen from 
                 other undo segments to satisfy space requests
UNXPBLKRELCNT  - The number of unexpired blocks removed from undo segments to be
                 used by other transactions
UNXPBLKREUCNT  - The number of unexpired undo blocks reused by transactions
EXPSTEALCNT    - The number of attempts when expired extents were stolen from 
                 other undo segments to satisfy a space requests
EXPBLKRELCNT   - The number of expired extents stolen from other undo segments 
                 to satisfy a space request
EXPBLKREUCNT   - The number of expired undo blocks reused within the same undo 
                 segments
SSOLDERRCNT    - The number of ORA-1555 errors that occurred during the interval
NOSPACEERRCNT  - The number of Out-of-Space errors

*/

set lines 120
set pages 200
column stealc format 999999
column relcnt format 999999
column reucnt format 999999
column undob format 999999
column queryl format 999999
column maxc format 9999

select to_char(end_time, 'DD.MM HH24:MI') ende 
     , undoblks undob
     , maxquerylen queryl
     , MAXCONCURRENCY maxc
     , NOSPACEERRCNT  nonspc
     , EXPSTEALCNT stealc
     , EXPBLKRELCNT relcnt
     , EXPBLKREUCNT reucnt
  from 
       (select end_time
             , undoblks
             , maxquerylen
             , MAXCONCURRENCY
             , NOSPACEERRCNT
             , EXPSTEALCNT
             , EXPBLKRELCNT
             , EXPBLKREUCNT
         from v$undostat
         order by end_time desc
       )
order by end_time 
;



