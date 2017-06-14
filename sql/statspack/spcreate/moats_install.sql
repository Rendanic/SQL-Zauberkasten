/*

Copyright Information
=====================
MOATS v1.06, April 2011
(c) Adrian Billington www.oracle-developer.net
(c) Tanel Poder       www.e2sn.com

Modifications by Kyle Hailey http://dboptimizer.com
for to add I/O histogram information 


*/

set define off

create or replace type moats_v2_ntt as table of varchar2(4000);
/

drop type moats_output_ntt;
drop type moats_output_ot;
create type moats_output_ot as object
( output varchar2(4000)
);
/
create or replace type moats_output_ntt as table of moats_output_ot;
/

drop type moats_ash_ntt;
drop type moats_ash_ot;
create type moats_ash_ot as object
( snaptime                      timestamp
, saddr                         raw(8)
, sid                           number
, serial#                       number
, audsid                        number
, paddr                         raw(8)
, user#                         number
, username                      varchar2(64)
, command                       number
, ownerid                       number
, taddr                         varchar2(64)
, lockwait                      varchar2(64)
, status                        varchar2(64)
, server                        varchar2(64)
, schema#                       number
, schemaname                    varchar2(64)
, osuser                        varchar2(64)
, process                       varchar2(64)
, machine                       varchar2(64)
, terminal                      varchar2(64)
, program                       varchar2(64)
, type                          varchar2(64)
, sql_address                   raw(8)
, sql_hash_value                number
, sql_id                        varchar2(64)
, sql_child_number              number
, prev_sql_addr                 raw(8)
, prev_hash_value               number
, prev_sql_id                   varchar2(64)
, prev_child_number             number
, module                        varchar2(64)
, module_hash                   number
, action                        varchar2(64)
, action_hash                   number
, client_info                   varchar2(64)
, fixed_table_sequence          number
, row_wait_obj#                 number
, row_wait_file#                number
, row_wait_block#               number
, row_wait_row#                 number
, logon_time                    date
, last_call_et                  number
, pdml_enabled                  varchar2(64)
, failover_type                 varchar2(64)
, failover_method               varchar2(64)
, failed_over                   varchar2(64)
, resource_consumer_group       varchar2(64)
, pdml_status                   varchar2(64)
, pddl_status                   varchar2(64)
, pq_status                     varchar2(64)
, current_queue_duration        number
, client_identifier             varchar2(64)
, blocking_session_status       varchar2(64)
, blocking_instance             number
, blocking_session              number
, seq#                          number
, event#                        number
, event                         varchar2(64)
, p1text                        varchar2(64)
, p1                            number
, p1raw                         raw(8)
, p2text                        varchar2(64)
, p2                            number
, p2raw                         raw(8)
, p3text                        varchar2(64)
, p3                            number
, p3raw                         raw(8)
, wait_class_id                 number
, wait_class#                   number
, wait_class                    varchar2(64)
, wait_time                     number
, seconds_in_wait               number
, state                         varchar2(64)
, service_name                  varchar2(64)
, sql_trace                     varchar2(64)
, sql_trace_waits               varchar2(64)
, sql_trace_binds               varchar2(64)
);
/
create or replace type moats_ash_ntt as table of moats_ash_ot;
/

drop type moats_event_ntt;
drop type moats_event_ot;
--   cursor hist_cur is select EVENT , TOTAL_WAITS  , TIME_WAITED
create type moats_event_ot as object ( event  varchar2(100) , total_waits  number , time_waited_micro number );
/
show errors
create or replace type moats_event_ntt as table of moats_event_ot;
/
show errors

drop type moats_hist_ntt;
drop type moats_hist_ot;
--   cursor hist_cur is select EVENT# , EVENT  , WAIT_TIME_MILLI, WAIT_COUNT
create type moats_hist_ot as object ( event  varchar2(100) , wait_time_milli  number , wait_count number );
/
show errors
create or replace type moats_hist_ntt as table of moats_hist_ot;
/
show errors

drop type moats_stat_ntt;
drop type moats_stat_ot;
create type moats_stat_ot as object ( type  varchar2(100) , name  varchar2(100) , value number );
/
show errors
create or replace type moats_stat_ntt as table of moats_stat_ot;
/
show errors


create or replace package moats as

   -- --------------------------------------------------------------------------
   -- MOATS v1.0 (c) Tanel Poder & Adrian Billington, 2010
   --
   -- See supplied README.txt for usage and disclaimers.
   --
   -- http://www.e2sn.com
   -- http://www.oracle-developer.net
   -- --------------------------------------------------------------------------

   -- Pipelined function to show TOP instance summary activity. The refresh rate
   -- defines how many ASH/SYSSTAT samples to take and is roughly equivalent to
   -- the number of seconds between screen refreshes...
   -- --------------------------------------------------------------------------
   function top (
            p_refresh_rate    in integer default null,
            p_ash_window_size in integer default null
            ) return moats_output_ntt pipelined;

   -- Helper procedure to size window to TOP output...
   -- --------------------------------------------------------------------------
   procedure format_window;

   -- Internal Use Only
   -- -----------------
   -- All functions and procedures from this point onwards are for internal use
   -- only in v1.01. Some of these will be exposed in future versions of MOATS.

   -- Pipelined function to return dynamic samples, queries, aggregations etc
   -- of active session data. The refresh rate defines (in seconds) how many
   -- ASH samples to take before running the query components...
   -- --------------------------------------------------------------------------
   function ash (
            p_refresh_rate in integer  default null,
            p_select       in varchar2 default null,
            p_where        in varchar2 default null,
            p_group_by     in varchar2 default null,
            p_order_by     in varchar2 default null
            ) return moats_output_ntt pipelined;

   -- Until 11g you can't bind UDTs into DBMS_SQL cursors, so this is an
   -- internal workaround. Can also be used to query all of the collected ASH
   -- samples. Note that gc_all_rows returns all ASH records between the two
   -- snapshots and gc_deltas returns only the lower and upper snapshots...
   -- --------------------------------------------------------------------------
   gc_all_rows constant pls_integer := 0;
   gc_deltas   constant pls_integer := 1;

   function get_ash (
            p_lower_snap in pls_integer default null,
            p_upper_snap in pls_integer default null,
            p_return_set in pls_integer default moats.gc_all_rows
            ) return moats_ash_ntt pipelined;

   -- Constants, get/set for moats parameters such as polling rate, ASH size...
   -- --------------------------------------------------------------------------
   gc_ash_polling_rate constant pls_integer := 0;
   gc_ash_threshold    constant pls_integer := 1;
   gc_top_refresh_rate constant pls_integer := 2;
   gc_ash_window_size  constant pls_integer := 3;

   procedure set_parameter(
             p_parameter_code  in pls_integer,
             p_parameter_value in integer
             );

   function get_parameter(
            p_parameter_code in pls_integer
            ) return integer;

   procedure restore_default_parameters;

   -- Debugging...
   -- --------------------------------------------------------------------------
   procedure show_snaps;

end moats;
/

create or replace package body moats as

   -- Internal types and global arrays for caching collections of
   -- SYSSTAT/ASH data for querying within MOATS...
   -- ------------------------------------------------------------------
   type moats_stat_ntt_aat is table of moats_stat_ntt index by pls_integer;
   g_stats moats_stat_ntt_aat;

   type moats_event_ntt_aat is table of moats_event_ntt index by pls_integer;
   g_event moats_event_ntt_aat;

   type moats_hist_ntt_aat is table of moats_hist_ntt index by pls_integer;
   g_hist moats_hist_ntt_aat;

   type moats_ash_ntt_aat is table of moats_ash_ntt
      index by pls_integer;
   g_ash moats_ash_ntt_aat;

   -- Internal type and variable for storing simple MOATS parameters...
   -- -----------------------------------------------------------------
   type parameter_aat is table of integer
      index by pls_integer;
   g_params parameter_aat;

   -- Variables for maintaining ASH/SYSSTAT collections...
   -- ----------------------------------------------------
   g_ash_size  pls_integer := 0;
   g_stat_size pls_integer := 0;

   -- General constants...
   -- --------------------
   gc_space       constant moats_output_ot := moats_output_ot(null);
   gc_clear       constant moats_output_ot := moats_output_ot('');
   gc_mb          constant pls_integer     := 1048576;
   gc_gb          constant pls_integer     := 1048576*1024;
   --gc_screen_size constant pls_integer     := 36;
   gc_screen_size constant pls_integer     := 50;
   gc_newline     constant varchar2(1)     := chr(10);

   ----------------------------------------------------------------------------
   procedure p( p_str in varchar2 ) is
   begin
      dbms_output.put_line(p_str);
   end p;

   ----------------------------------------------------------------------------
   procedure po( p_str in moats_output_ot ) is
   begin
      p(p_str.output);
   end po;

--   ----------------------------------------------------------------------------
--   procedure dump_ash is
--      pragma autonomous_transaction;
--   begin
--      insert into moats_ash_dump select * from table(moats.get_ash);
--      commit;
--   end dump_ash;

   ----------------------------------------------------------------------------
   procedure show_snaps is
      v_indx pls_integer;
   begin
      p('ASH snaps...');
      p('------------------------------------');
      v_indx := g_ash.first;
      while v_indx is not null loop
         p(utl_lms.format_message('Index=[%d] Count=[%d]', v_indx, g_ash(v_indx).count));
         v_indx := g_ash.next(v_indx);
      end loop;
      p('STAT snaps...');
      p('------------------------------------');
      v_indx := g_stats.first;
      while v_indx is not null loop
         p(utl_lms.format_message('Index=[%d] Count=[%d]', v_indx, g_stats(v_indx).count));
         v_indx := g_stats.next(v_indx);
      end loop;
      p('HIST snaps...');
      v_indx := g_hist.first;
      while v_indx is not null loop
         p(utl_lms.format_message('Index=[%d] Count=[%d]', v_indx, g_hist(v_indx).count));
         v_indx := g_hist.next(v_indx);
      end loop;
   end show_snaps;

   ----------------------------------------------------------------------------
   function banner return moats_output_ntt is
   begin
      return moats_output_ntt(
                moats_output_ot('MOATS: The Mother Of All Tuning Scripts v1.0 by Adrian Billington & Tanel Poder'),
                moats_output_ot('       http://www.oracle-developer.net & http://www.e2sn.com')
                );
   end banner;

   ----------------------------------------------------------------------------
   function to_string ( p_collection in moats_v2_ntt,
                        p_delimiter  in varchar2 default ',',
                        p_elements   in pls_integer default null ) return varchar2 is
      v_str varchar2(4000);
   begin
      for i in 1 .. least(nvl(p_elements, p_collection.count), p_collection.count) loop
         v_str := v_str || p_delimiter || p_collection(i);
      end loop;
      return ltrim(v_str, p_delimiter);
   end to_string;

   ----------------------------------------------------------------------------
   procedure format_window is
      v_banner   moats_output_ntt := banner();
      c_boundary varchar2(110)    := rpad('-',110,'-');
      procedure spaces( p_spaces in pls_integer ) is
      begin
         for i in 1 .. p_spaces loop
            po(gc_space);
         end loop;
      end spaces;
   begin
      p(c_boundary);
      spaces(2);
      for i in 1 .. v_banner.count loop
         p(v_banner(i).output);
      end loop;
      spaces(3);
      p('       MOATS.FORMAT_WINDOW');
      p('       -------------------');
      p('       Align sqlplus window size to dotted lines for optimal output');
      spaces(gc_screen_size-10);
      p(c_boundary);
   end format_window;

   ----------------------------------------------------------------------------
   procedure set_parameter( p_parameter_code  in pls_integer,
                            p_parameter_value in integer ) is
   begin
      g_params(p_parameter_code) := p_parameter_value;
   end set_parameter;

   ----------------------------------------------------------------------------
   function get_parameter ( p_parameter_code in pls_integer ) return integer is
   begin
      return g_params(p_parameter_code);
   end get_parameter;

   ----------------------------------------------------------------------------
   procedure restore_default_parameters is
   begin
      set_parameter(moats.gc_ash_polling_rate, 1);
      set_parameter(moats.gc_ash_threshold, 1000);
      set_parameter(moats.gc_top_refresh_rate, 10);
      -- By default don't use a trailing ASH window
      set_parameter(moats.gc_ash_window_size, NULL);
   end restore_default_parameters;

   ----------------------------------------------------------------------------
   function get_sql( p_select   in varchar2,
                     p_from     in varchar2,
                     p_where    in varchar2,
                     p_group_by in varchar2,
                     p_order_by in varchar2 ) return varchar2 is
      v_sql varchar2(32767);
   begin
      v_sql := 'select ' || nvl(p_select, '*') || ' from ' || p_from;
      if p_where is not null then
         v_sql := v_sql || ' where ' || p_where;
      end if;
      if p_group_by is not null then
         v_sql := v_sql || ' group by ' || p_group_by;
      end if;
      if p_order_by is not null then
         v_sql := v_sql || ' order by ' || p_order_by;
      end if;
      return v_sql;
   end get_sql;

   ----------------------------------------------------------------------------
   function ash_history return interval day to second is
   begin
      return g_ash(g_ash.last)(1).snaptime - g_ash(g_ash.first)(1).snaptime;
   end ash_history;

   ----------------------------------------------------------------------------
   function ash_sample_count( p_lower_snap in pls_integer,
                              p_upper_snap in pls_integer ) return pls_integer is
      v_samples pls_integer := 0;
      v_snap    pls_integer;
      v_exit    boolean := false;
   begin
      v_snap := p_lower_snap;
      while v_snap is not null and not v_exit loop
         -- Ignore dummy record
         if not (g_ash(v_snap).count = 1 and g_ash(v_snap)(1).sid is null) then
            v_samples := v_samples + g_ash(v_snap).count;
         end if;
         v_exit := (v_snap = p_upper_snap);
         v_snap := g_ash.next(v_snap);
      end loop;
      return greatest(v_samples,1);
   end ash_sample_count;

   ----------------------------------------------------------------------------
   procedure maintain_ash_collection( p_index in pls_integer ) is
   begin
      if g_ash(p_index).count = 0 then
         g_ash.delete(p_index);
      else
         g_ash_size := g_ash_size + g_ash(p_index).count;
         while g_ash_size > g_params(moats.gc_ash_threshold) loop
            g_ash_size := g_ash_size - g_ash(g_ash.first).count;
            g_ash.delete(g_ash.first);
         end loop;
      end if;
   end maintain_ash_collection;

   ----------------------------------------------------------------------------
   procedure snap_ash( p_index in pls_integer ) is
      v_sql_template varchar2(32767);
      v_sql          varchar2(32767);
   begin

      -- TODO: conditional compilation to get correct column list for version or
      -- select a small bunch of useful columns

      -- Use dynamic SQL to avoid explicit grants on V$SESSION. Prepare the start
      -- of the SQL as it will be used twice...
      -- ------------------------------------------------------------------------
      v_sql_template := q'[select moats_ash_ot( 
                                     systimestamp, saddr, %sid%, serial#, audsid, paddr, user#,
                                     username, command, ownerid, taddr, lockwait,
                                     status, server, schema#, schemaname, osuser,
                                     process, machine, terminal, program, type,
                                     sql_address, sql_hash_value, sql_id, sql_child_number,
                                     prev_sql_addr, prev_hash_value, prev_sql_id,
                                     prev_child_number, module, module_hash, action,
                                     action_hash, client_info, fixed_table_sequence,
                                     row_wait_obj#, row_wait_file#, row_wait_block#,
                                     row_wait_row#, logon_time, last_call_et, pdml_enabled,
                                     failover_type, failover_method, failed_over,
                                     resource_consumer_group, pdml_status, pddl_status,
                                     pq_status, current_queue_duration, client_identifier,
                                     blocking_session_status, blocking_instance,
                                     blocking_session, seq#, event#, case when state = 'WAITING' then event else 'ON CPU' end, p1text, p1,
                                     p1raw, p2text, p2, p2raw, p3text, p3, p3raw,
                                     wait_class_id, wait_class#, case when state = 'WAITING' then wait_class else 'ON CPU' end, wait_time,
                                     seconds_in_wait, state, service_name, sql_trace,
                                     sql_trace_waits, sql_trace_binds
                                     )
                           from   v$session
                           where  %preds%]';

      v_sql := replace( v_sql_template, '%sid%', 'sid');
      v_sql := replace( v_sql, '%preds%',  q'[    status = 'ACTIVE'
                                              and (wait_class != 'Idle' or state != 'WAITING')
                                              and  sid != sys_context('userenv', 'sid')]' );
                           
      execute immediate v_sql bulk collect into g_ash(p_index);

      -- If we have nothing to snap, add a dummy record that will be ignored
      -- in GET_ASH and GET_ASH_SAMPLE_COUNT...
      -- -------------------------------------------------------------------
      if g_ash(p_index).count = 0 then
         v_sql := replace( v_sql_template, '%sid%', 'null');
         v_sql := replace( v_sql, '%preds%', q'[sid = sys_context('userenv', 'sid')]' );
         execute immediate v_sql bulk collect into g_ash(p_index);
      end if;

      maintain_ash_collection(p_index);

   end snap_ash;

   ----------------------------------------------------------------------------
   procedure reset_stats_collection is
   begin
      g_stats.delete;
   end reset_stats_collection;

   ----------------------------------------------------------------------------
   procedure reset_hist_collection is
   begin
      g_hist.delete;
   end reset_hist_collection;

   ----------------------------------------------------------------------------
   procedure reset_event_collection is
   begin
      g_event.delete;
   end reset_event_collection;

   ----------------------------------------------------------------------------
   procedure snap_event( p_index in pls_integer,
                         p_reset in boolean default false ) is
   begin

      if p_reset then
         reset_event_collection();
      end if;

      -- Use dynamic SQL to avoid explicit grants on V$ views...
      -- -------------------------------------------------------
      execute immediate
         q'[select moats_event_ot(event, total_waits, time_waited_micro )
            from (
                   select
                            event,
                            total_waits,
                            time_waited_micro
                   from
                        v$system_event
                   where
                      event in (
                                 'log file sync',
                                 'log file parallel write',
                                 'db file scattered read',
                                 'db file sequential read',
                                 'direct path read',
                                 'direct path read temp',
                                 'direct path write',
                                 'direct path write temp')
                 )]'
   bulk collect into g_event(p_index);

   end snap_event;

   ----------------------------------------------------------------------------
   procedure snap_hist( p_index in pls_integer,
                        p_reset in boolean default false ) is
   begin

      if p_reset then
         reset_hist_collection();
      end if;

      -- Use dynamic SQL to avoid explicit grants on V$ views...
      -- -------------------------------------------------------
      execute immediate
         q'[select moats_hist_ot(event, wait_time_milli, wait_count)
            from (
                   select
                            z.event,
                            z.wait_time_milli,
                            sum(nvl(l.wait_count,0) + z.wait_count) wait_count
                   from
                   (  select  EVENT  , WAIT_TIME_MILLI, WAIT_COUNT
                      from    v$event_histogram
                      where
                      event in (
                                 'log file sync',
                                 'log file parallel write',
                                 'db file scattered read',
                                 'db file sequential read',
                                 'direct path read',
                                 'direct path read temp',
                                 'direct path write',
                                 'direct path write temp'
                               )
                   ) l,
                   (
                    select e.event, w.wait_time_milli,w.wait_count from
                     (
                      select 'log file parallel write'  event from dual union all
                      select 'log file sync'            event from dual union all
                      select 'db file scattered read'   event from dual union all
                      select 'db file sequential read'  event from dual union all  
                      select 'direct path read'         event from dual union all
                      select 'direct path read temp'    event from dual union all
                      select 'direct path write'        event from dual union all
                      select 'direct path write temp'   event from dual 
                     ) e,
                     (
                      select   1 WAIT_TIME_MILLI, 0 WAIT_COUNT from dual union all
                      select   2 WAIT_TIME_MILLI, 0 WAIT_COUNT from dual union all
                      select   4 WAIT_TIME_MILLI, 0 WAIT_COUNT from dual union all
                      select   8 WAIT_TIME_MILLI, 0 WAIT_COUNT from dual union all
                      select  16 WAIT_TIME_MILLI, 0 WAIT_COUNT from dual union all
                      select  32 WAIT_TIME_MILLI, 0 WAIT_COUNT from dual union all
                      select  64 WAIT_TIME_MILLI, 0 WAIT_COUNT from dual union all
                      select  128 WAIT_TIME_MILLI, 0 WAIT_COUNT from dual union all
                      select  256 WAIT_TIME_MILLI, 0 WAIT_COUNT from dual union all
                      select  512 WAIT_TIME_MILLI, 0 WAIT_COUNT from dual union all
                      select  1024 WAIT_TIME_MILLI, 0 WAIT_COUNT from dual union all
                      select  2048 WAIT_TIME_MILLI, 0 WAIT_COUNT from dual union all
                      select  4096 WAIT_TIME_MILLI, 0 WAIT_COUNT from dual union all
                      select  8192 WAIT_TIME_MILLI, 0 WAIT_COUNT from dual union all
                      select  16384 WAIT_TIME_MILLI, 0 WAIT_COUNT from dual union all
                      select  32769 WAIT_TIME_MILLI, 0 WAIT_COUNT from dual union all
                      select  65536 WAIT_TIME_MILLI, 0 WAIT_COUNT from dual union all
                      select  131072 WAIT_TIME_MILLI, 0 WAIT_COUNT from dual union all
                      select  262144 WAIT_TIME_MILLI, 0 WAIT_COUNT from dual union all
                      select  524288 WAIT_TIME_MILLI, 0 WAIT_COUNT from dual union all
                      select  1048576 WAIT_TIME_MILLI, 0 WAIT_COUNT from dual union all
                      select  2097152 WAIT_TIME_MILLI, 0 WAIT_COUNT from dual union all
                      select  4194304 WAIT_TIME_MILLI, 0 WAIT_COUNT from dual
                    ) w
                   ) z
                   where z.wait_time_milli = l.wait_time_milli (+)
                   and   z.event = l.event (+)
                   group by z.event,z.wait_time_milli
                   order by z.event,z.wait_time_milli
                 )]'
   bulk collect into g_hist(p_index);

   end snap_hist;

   ----------------------------------------------------------------------------
   procedure snap_stats( p_index in pls_integer,
                         p_reset in boolean default false ) is
   begin

      if p_reset then
         reset_stats_collection();
      end if;

      -- Use dynamic SQL to avoid explicit grants on V$ views...
      -- -------------------------------------------------------
      execute immediate
         q'[select moats_stat_ot(type, name, value)
            from (
                  select 'STAT' as type
                  ,      sn.name
                  ,      ss.value
                  from   v$statname sn
                  ,      v$sysstat  ss
                  where  sn.statistic# = ss.statistic#
                  union all
                  select 'LATCH'
                  ,      name
                  ,      gets
                  from   v$latch
                  union all
                  select 'TIMER'
                  ,      'moats timer'
                  ,      hsecs
                  from   v$timer
                 )]'
      bulk collect into g_stats(p_index);

   end snap_stats;

   ----------------------------------------------------------------------------
   function instance_summary ( p_lower_snap in pls_integer,
                               p_upper_snap in pls_integer ) return moats_output_ntt is

      type event_aat        is table of varchar2(64) index by pls_integer;
      type metric_aat       is table of number index by pls_integer;
      type hist_aat         is table of number index by pls_integer;
      type event_time_aat   is table of number index by pls_integer;
      type event_count_aat  is table of number index by pls_integer;
      v_event_time   event_time_aat;
      v_event_count  event_count_aat;
      v_rows         moats_output_ntt := moats_output_ntt();
      v_waits        event_aat; 
      v_metrics      metric_aat;
      v_secs         number;                 --<-- seconds between 2 stats snaps
      v_hivl         interval day to second; --<-- interval of ASH history saved
      v_hstr         varchar2(30);           --<-- formatted hh:mi:ss string of history
      v_hist_i       number;               
      v_rown         number;               
      v_hist         hist_aat;

   begin

      -- Get long and short metrics for range of stats. Order for fixed array offset...
      -- ------------------------------------------------------------------------------
      select upr.value - lwr.value
      bulk collect into v_metrics
      from   table(g_stats(p_lower_snap)) lwr
      ,      table(g_stats(p_upper_snap)) upr
      where  lwr.name = upr.name
      and    lwr.name in ('execute count', 'parse count (hard)', 'parse count (total)',
                          'physical read total IO requests', 'physical read total bytes',
                          'physical write total IO requests', 'physical write total bytes',
                          'redo size', 'redo writes', 'session cursor cache hits',
                          'session logical reads', 'user calls', 'user commits',
                          'moats timer')
      order  by
             lwr.name;
      
      select upr.total_waits - lwr.total_waits,
             upr.time_waited_micro - lwr.time_waited_micro
      bulk collect into v_event_count, v_event_time
      from   table(g_event(p_lower_snap)) lwr
      ,      table(g_event(p_upper_snap)) upr
      where  
             lwr.event = upr.event
      order  by upr.event;

      -- 0 db file scattered read
      -- 1 db file sequential read
      -- 2 direct path read
      -- 3 direct path read temp
      -- 4 direct path write
      -- 5 direct path write temp
      -- 6 log file parallel write
      -- 7 log file sync

      select upr.wait_count - lwr.wait_count
      bulk collect into v_hist
      from   table(g_hist(p_lower_snap)) lwr
      ,      table(g_hist(p_upper_snap)) upr
      where  lwr.wait_time_milli = upr.wait_time_milli
      and    lwr.event = upr.event
      order  by upr.event, upr.wait_time_milli;

      -- 1  execute count
      -- 2  moats timer
      -- 3  parse count (hard)
      -- 4  parse count (total)
      -- 5  physical read total IO requests
      -- 6  physical read total bytes
      -- 7  physical write total IO requests
      -- 8  physical write total bytes
      -- 9  redo size
      -- 10 redo writes
      -- 11 session cursor cache hits
      -- 12 session logical reads
      -- 13 user calls
      -- 14 user commits

      -- Execs/s:     execute count
      -- sParse/s:    parse count (total)
      -- LIOs/s:      session logical reads
      -- Read MB/s:   physical read total bytes / 1048576
      -- Calls/s:     user calls
      -- hParse/s:    parse count (hard)
      -- PhyRD/s:     physical read total IO requests
      -- PhyWR/s:     physical write total IO requests
      -- Write MB/s:  physical write total bytes / 1048576
      -- History:
      -- Commits/s:   user commits
      -- ccHits/s:    session cursor cache hits
      -- Redo MB/s:   redo size

      -- Calculate number of seconds...
      -- ------------------------------
      v_secs := v_metrics(2)/100;

      -- Calculate ASH history...
      -- ------------------------
      v_hivl := ash_history();
      v_hstr := to_char(extract(hour from v_hivl))   || 'h ' ||
                to_char(extract(minute from v_hivl)) || 'm ' ||
                to_char(trunc(extract(second from v_hivl))) || 's';

      -- Set the instance summary output...
      -- ----------------------------------
      v_rows.extend(14);
      v_rows(1) := moats_output_ot(rpad('+ INSTANCE SUMMARY ',109,'-') || '+');
      v_rows(2) := moats_output_ot(
                      rpad('| Instance: ' || sys_context('userenv','instance_name'), 28) ||
                      ' | Execs/s: ' || lpad(to_char(v_metrics(1)/v_secs, 'fm99990.0'), 7) ||
                      ' | sParse/s: ' || lpad(to_char((v_metrics(4)-v_metrics(3))/v_secs, 'fm99990.0'), 7) ||
                      ' | LIOs/s: ' || lpad(to_char(v_metrics(12)/v_secs, 'fm9999990.0'), 9) ||
                      ' | Read MB/s: ' || lpad(to_char(v_metrics(6)/v_secs/gc_mb, 'fm99990.0'), 7) ||
                      ' |');
      v_rows(3) := moats_output_ot(
                      rpad('| Cur Time: ' || to_char(sysdate, 'DD-Mon hh24:mi:ss'), 28) ||
                      ' | Calls/s: ' || lpad(to_char(v_metrics(13)/v_secs, 'fm99990.0'), 7) ||
                      ' | hParse/s: ' || lpad(to_char(v_metrics(3)/v_secs, 'fm99990.0'), 7) ||
                      ' | PhyRD/s: ' || lpad(to_char(v_metrics(5)/v_secs, 'fm999990.0'), 8) ||
                      ' | Write MB/s: ' || lpad(to_char(v_metrics(8)/v_secs/gc_mb, 'fm9990.0'), 6) ||
                      ' |');
      v_rows(4) := moats_output_ot(
                      rpad('| History:  ' || v_hstr, 28) ||
                      ' | Commits/s: ' || lpad(to_char(v_metrics(14)/v_secs, 'fm990.0'), 5) ||
                      ' | ccHits/s: ' || lpad(to_char(v_metrics(11)/v_secs, 'fm99990.0'), 7) ||
                      ' | PhyWR/s: ' || lpad(to_char(v_metrics(7)/v_secs, 'fm999990.0'), 8) ||
                      ' | Redo MB/s: ' || lpad(to_char(v_metrics(9)/v_secs/gc_mb, 'fm99990.0'), 7) ||
                      ' |');
      v_rows(5) := moats_output_ot(rpad('+-',109,'-') || '+');

      v_waits(0):='db file scattered read';
      v_waits(1):='db file sequential read';
      v_waits(2):='direct path read';
      v_waits(3):='direct path read temp';
      v_waits(4):='direct path write';
      v_waits(5):='direct path write temp';
      v_waits(6):='log file parallel write';
      v_waits(7):='log file sync';
      
      v_rows(6) := moats_output_ot(
                       '| ' ||
                       lpad('event name',21,' ') ||
                       lpad('avg ms',7,' ') ||
                       lpad('1ms',6,' ') ||
                       lpad('2ms',6,' ') ||
                       lpad('4ms',6,' ') ||
                       lpad('8ms',6,' ') ||
                       lpad('16ms',6,' ') ||
                       lpad('32ms',6,' ') ||
                       lpad('64ms',6,' ') ||
                       lpad('128ms',6,' ') ||
                       lpad('256ms',6,' ') ||
                       lpad('512ms',6,' ') ||
                       lpad('1s',6,' ') ||
                       lpad('2s+',6,' ') ||
                       lpad('4s+',6,' ') ||
                       ' |');

      FOR i IN 0..7 LOOP
          v_rown:=7+i;
          v_rows(v_rown) := moats_output_ot( '| ' || lpad(v_waits(i),21,' ') || lpad(' ',  85 , ' ' ) || ' |');
      END LOOP;

      FOR i IN 0..7 LOOP
        v_hist_i:=i*23;
        v_rown:=7+i;
        v_rows(v_rown) := moats_output_ot(
                       '| ' ||
                       lpad(v_waits(i),21,' ') ||
                       replace(lpad(nvl(round(
                                       (v_event_time(i+1)/1000)/nullif(v_event_count(i+1),0)
                               ,3),0),7,' '),' 0','  ') ||
                       replace(lpad(to_char(v_hist(v_hist_i + 1)),6,' '),' 0','  ') ||
                       replace(lpad(to_char(v_hist(v_hist_i + 2)),6,' '),' 0','  ') ||
                       replace(lpad(to_char(v_hist(v_hist_i + 3)),6,' '),' 0','  ') ||
                       replace(lpad(to_char(v_hist(v_hist_i + 4)),6,' '),' 0','  ') ||
                       replace(lpad(to_char(v_hist(v_hist_i + 5)),6,' '),' 0','  ') ||
                       replace(lpad(to_char(v_hist(v_hist_i + 6)),6,' '),' 0','  ') ||
                       replace(lpad(to_char(v_hist(v_hist_i + 7)),6,' '),' 0','  ') ||
                       replace(lpad(to_char(v_hist(v_hist_i + 8)),6,' '),' 0','  ') ||
                       replace(lpad(to_char(v_hist(v_hist_i + 9)),6,' '),' 0','  ') ||
                       replace(lpad(to_char(v_hist(v_hist_i + 10)),6,' '),' 0','  ') ||
                       replace(lpad(to_char(v_hist(v_hist_i + 11)),6,' '),' 0','  ') ||
                       replace(lpad(to_char(v_hist(v_hist_i + 12)),6,' '),' 0','  ') ||
                       replace(lpad(to_char( v_hist(v_hist_i + 13) +
                                     v_hist(v_hist_i + 14) +
                                     v_hist(v_hist_i + 15) +
                                     v_hist(v_hist_i + 16) +
                                     v_hist(v_hist_i + 17) +
                                     v_hist(v_hist_i + 18) +
                                     v_hist(v_hist_i + 19) +
                                     v_hist(v_hist_i + 20) +
                                     v_hist(v_hist_i + 21) +
                                     v_hist(v_hist_i + 22) +
                                     v_hist(v_hist_i + 23) ) ,6,' '),' 0','  ') ||
                      ' |');
      END LOOP;
      return v_rows;
    exception
      when no_data_found then
         --null;
         -- raise_application_error(-20001, 'Error: '||sqlerrm||' at:'||chr(10)||dbms_utility.format_error_backtrace);
         -- v_rows(v_rown) := moats_output_ot( '| ' || lpad(v_waits(i),21,' ') || lpad(' ',  85 , ' ' ) || ' |');
                 return v_rows;

   end instance_summary;

   ----------------------------------------------------------------------------
   function top_summary ( p_lower_snap in pls_integer,
                          p_upper_snap in pls_integer ) return moats_output_ntt is

      type top_sql_rt is record
      ( sql_id           varchar2(64)
      , sql_child_number number
      , occurrences      number
      , top_sids         moats_v2_ntt );

      type top_waits_rt is record
      ( wait_name   varchar2(64)
      , wait_class  varchar2(64)
      , occurrences number );

      type top_sql_aat is table of top_sql_rt
         index by pls_integer;

      type top_waits_aat is table of top_waits_rt
         index by pls_integer;

      v_row       varchar2(4000);
      v_rows      moats_output_ntt := moats_output_ntt();
      v_top_sqls  top_sql_aat;
      v_top_waits top_waits_aat;
      v_samples   pls_integer;

   begin

      -- Calculate number of ASH samples for this output...
      -- --------------------------------------------------
      v_samples := ash_sample_count( p_lower_snap => p_lower_snap,
                                     p_upper_snap => p_upper_snap );

      -- Begin TOP summary...
      -- --------------------
      v_rows.extend;
      v_rows(1) := moats_output_ot(
                      rpad('+ TOP SQL_ID (child#) ',27,'-') ||
                      rpad('+ TOP SESSIONS ',24,'-') ||
                      rpad('+',7) ||
                      rpad('+ TOP WAITS ',37,'-') || '+ WAIT CLASS -+'
                      );

      -- Top SQL_IDs...
      -- --------------
      with ash_data as (
              select sid, sql_id, sql_child_number
              from   table(
                        moats.get_ash(
                           p_lower_snap, p_upper_snap, moats.gc_all_rows))
              )
      select o_ash.sql_id
      ,      o_ash.sql_child_number
      ,      o_ash.occurrences
      ,      cast(
                multiset(
                   select i_ash.sid
                   from   ash_data i_ash
                   where  i_ash.sql_id = o_ash.sql_id
                   and    i_ash.sql_child_number = o_ash.sql_child_number
                   group  by
                          i_ash.sid
                   order  by
                          count(*) desc
                   ) as moats_v2_ntt) as top_sids
      bulk collect into v_top_sqls
      from  (
             select sql_id
             ,      sql_child_number
             ,      count(*) as occurrences
             from   ash_data
             group  by
                    sql_id
             ,      sql_child_number
             order  by
                    count(*) desc
            ) o_ash
      where  rownum <= 5;

      -- Top waits...
      -- ------------
      select substr(event,1,48)
      ,      wait_class
      ,      occurrences
      bulk collect into v_top_waits
      from  (
             select event
             ,      wait_class
             ,      count(*) as occurrences
             from   table(
                       moats.get_ash(
                          p_lower_snap, p_upper_snap, moats.gc_all_rows))
             group  by
                    event
             ,      wait_class
             order  by
                    count(*) desc
            )
      where  rownum <= 5;

      -- Summary output...
      -- -----------------
      for i in 1 .. greatest(v_top_sqls.count, v_top_waits.count) loop
         v_rows.extend;
         v_row := case
                     when v_top_sqls.exists(i)
                     then '|' || lpad(to_char((v_top_sqls(i).occurrences/v_samples)*100, 'fm9999'),4) || '% ' ||
                          rpad('| ' || v_top_sqls(i).sql_id || ' (' || v_top_sqls(i).sql_child_number || ')', 20) ||
                          rpad('| ' || to_string(v_top_sqls(i).top_sids, p_elements => 5), 23) ||
                          rpad(' |', 8)
                     else  rpad('|', 7) ||
                           rpad('| ', 20) ||
                           rpad('| ', 23) ||
                           rpad(' |', 8)
                  end;
         v_row := v_row ||
                  case
                     when v_top_waits.exists(i)
                     then '|' || lpad(to_char((v_top_waits(i).occurrences/v_samples)*100, 'fm9999'),4) || '% ' ||
                          rpad('| ' || substr(v_top_waits(i).wait_name,1,35), 29) ||
                          rpad(' | ' || v_top_waits(i).wait_class, 15) || '|'
                     else  rpad('|', 7) ||
                           rpad('| ', 29) ||
                           rpad(' | ', 15) ||
                           '|'
                  end;

         v_rows(v_rows.last) := moats_output_ot(v_row);
      end loop;

      v_rows.extend(2);
      v_rows(v_rows.last-1) := moats_output_ot(
                                rpad('+',51,'-') || rpad('+',7) || rpad('+',51,'-') || '+'
                                );
      v_rows(v_rows.last) := gc_space;

      -- Top SQL output - we're going to deliberately loop r-b-r for the sql_ids...
      -- --------------------------------------------------------------------------
      v_rows.extend;
      v_rows(v_rows.last) := moats_output_ot(
                                rpad('+ TOP SQL_ID ----+ PLAN_HASH_VALUE + SQL TEXT ', 109, '-') || '+'
                                );
      for i in 1 .. v_top_sqls.count loop
         for r_sql in (select sql_id, child_number, sql_text, plan_hash_value
                       from   v$sql
                       where  sql_id = v_top_sqls(i).sql_id
                       and    child_number = v_top_sqls(i).sql_child_number)
         loop
            v_rows.extend;
            v_rows(v_rows.last) := moats_output_ot(
                                      rpad('| ' || r_sql.sql_id, 17) ||
                                      rpad('| ' || r_sql.plan_hash_value, 18) ||
                                      rpad('| ' || substr(r_sql.sql_text, 1, 71), 73) || ' |'
                                      );
            if length(r_sql.sql_text) > 74 then
               v_rows.extend;
               v_rows(v_rows.last) := moats_output_ot(
                                         rpad('| ', 17) ||
                                         rpad('| ', 18) ||
                                         rpad('| ' || substr(r_sql.sql_text, 72, 71), 73) || ' |'
                                         );
            end if;
            v_rows.extend;
            v_rows(v_rows.last) := moats_output_ot(
                                      rpad('+ ', 17, '-') ||
                                      rpad('-', 18, '-') ||
                                      rpad('-', 73, '-') || ' +'
                                      );
         end loop;
      end loop;

      return v_rows;

   end top_summary;

   ----------------------------------------------------------------------------
   procedure poll( p_refresh_rate in  integer,
                   p_include_ash  in  boolean,
                   p_include_stat in  boolean,
                   p_include_hist in  boolean,
                   p_include_event in  boolean,
                   p_lower_snap   out pls_integer,
                   p_upper_snap   out pls_integer ) is

      v_index        pls_integer;
      v_refresh_rate integer := nvl(p_refresh_rate, g_params(moats.gc_top_refresh_rate));

      function snap_index return pls_integer is
      begin
         return dbms_utility.get_time();
      end snap_index;

   begin

      -- Set starting snap index...
      -- --------------------------
      v_index := snap_index();
      p_lower_snap := v_index;

      -- Snap SYSSTAT if required...
      -- ---------------------------
      if p_include_stat then
         snap_stats(v_index, true);
      end if;

      -- Snap HISTOGRAMS if required...
      -- ---------------------------
      if p_include_hist then
         snap_hist(v_index, true);
      end if;

      -- Snap EVENTS if required...
      -- ---------------------------
      if p_include_hist then
         snap_event(v_index, true);
      end if;

      -- Snap ASH if required...
      -- -----------------------
      if p_include_ash then
         for i in 1 .. ceil(v_refresh_rate/g_params(moats.gc_ash_polling_rate)) loop
            if i > 1 then
              v_index := snap_index;
            end if;
            snap_ash(v_index);
            dbms_lock.sleep(g_params(moats.gc_ash_polling_rate));
         end loop;
      end if;

      -- If no ASH samples taken, sleep for refresh rate instead...
      -- ----------------------------------------------------------
      if p_include_stat and not p_include_ash then
         dbms_lock.sleep(v_refresh_rate);
         v_index := snap_index;
      end if;

      -- Snap SYSSTAT again if required...
      -- ---------------------------------
      if p_include_stat then
         snap_stats(v_index);
      end if;

      -- Snap HISTOGRAMS if required...
      -- ---------------------------
      if p_include_hist then
         snap_hist(v_index);
      end if;

      -- Snap EVENTS if required...
      -- ---------------------------
      if p_include_hist then
         snap_event(v_index);
      end if;


      -- Set end snap index...
      -- ---------------------
      p_upper_snap := v_index;

   end poll;

   ----------------------------------------------------------------------------
   -- Determine ASH trailing window size
   ----------------------------------------------------------------------------
   function get_ash_window_lower_snap (
        p_lower_snap      in pls_integer,
        p_upper_snap      in pls_integer,
        p_refresh_rate    in pls_integer,
        p_ash_window_size in pls_integer
        ) return pls_integer is

      v_snap_count      pls_integer;
      v_snap            pls_integer;
      v_ash_window_size pls_integer;
   begin
      v_ash_window_size := nvl(p_ash_window_size, get_parameter(moats.gc_ash_window_size));
      -- By default no ASH trailing window or if refresh rate greater than window size
      -- -----------------------------------------------------------------------------
      if v_ash_window_size is null or p_refresh_rate >= v_ash_window_size then
         v_snap := p_lower_snap;
      else
         v_snap_count := 1;
         v_snap := p_upper_snap;
         while v_snap_count < v_ash_window_size and g_ash.prior(v_snap) is not null loop
           v_snap_count := v_snap_count + 1;
           v_snap := g_ash.prior(v_snap);
         end loop;
      end if;

      return v_snap;
   end get_ash_window_lower_snap;

   ----------------------------------------------------------------------------
   function top (
            p_refresh_rate    in integer default null,
            p_ash_window_size in integer default null
            ) return moats_output_ntt pipelined is

      v_lower_snap pls_integer;
      v_upper_snap pls_integer;
      v_row        varchar2(4000);
      v_rows       moats_output_ntt := moats_output_ntt();
      v_cnt        pls_integer := 0;

   begin

      -- Initial clear screen and stabiliser...
      -- --------------------------------------
      v_rows := banner();
      -- fill the initial "blank screen" (this is needed for arraysize = 72 to work)   
      for i in 1 .. gc_screen_size loop
         pipe row (gc_space);
      end loop;
      -- print banner onto the top of the screen
      for i in 1 .. v_rows.count loop
         pipe row (v_rows(i));
      end loop;
      -- fill the rest of the visible screen
      for i in 1 .. gc_screen_size-(v_rows.count+1) loop
         pipe row (gc_space);
      end loop;
      pipe row (moats_output_ot('Please wait : fetching data for first refresh...'));

      -- Begin TOP refreshes...
      -- ----------------------
      loop

         -- Clear screen...
         -- ---------------
         for i in 1 .. gc_screen_size loop
            pipe row (gc_space);
         end loop;
         --pipe row (gc_space);
	 --pipe row (gc_clear);

         -- Take some ASH/STAT samples...
         -- -----------------------------
         poll( p_refresh_rate => p_refresh_rate,
               p_include_ash  => true,
               p_include_stat => true,
               p_include_hist => true,
               p_include_event => true,
               p_lower_snap   => v_lower_snap,
               p_upper_snap   => v_upper_snap );

         -- Banner...
         -- ---------
         v_rows := banner();
         for i in 1 .. v_rows.count loop
            pipe row (v_rows(i));
         end loop;
         pipe row (gc_space);
         v_cnt := v_rows.count + 1;

         -- Instance summary...
         -- -------------------
         v_rows := instance_summary( p_lower_snap => v_lower_snap,
                                     p_upper_snap => v_upper_snap );
         for i in 1 .. v_rows.count loop
            pipe row (v_rows(i));
         end loop;
         pipe row (gc_space);
         v_cnt := v_cnt + v_rows.count + 1;

         v_lower_snap := get_ash_window_lower_snap( p_lower_snap => v_lower_snap,
                                                    p_upper_snap => v_upper_snap,
                                                    p_refresh_rate => p_refresh_rate,
                                                    p_ash_window_size => p_ash_window_size );

         -- Top SQL and waits section...
         -- ----------------------------
         v_rows := top_summary( p_lower_snap => v_lower_snap,
                                p_upper_snap => v_upper_snap );
         for i in 1 .. v_rows.count loop
            pipe row (v_rows(i));
         end loop;
         pipe row (gc_space);
         v_cnt := v_cnt + v_rows.count + 1;

         -- Some blank output...
         -- --------------------
         if v_cnt < (gc_screen_size) then
            for i in 1 .. (gc_screen_size)-v_cnt loop
               pipe row (gc_space);
            end loop;
         end if;

      end loop;
      return;

   exception
      when no_data_found then
         raise_application_error(-20000, 'Error: '||sqlerrm||' at:'||chr(10)||dbms_utility.format_error_backtrace);
   end top;

   ----------------------------------------------------------------------------
   function ash (
            p_refresh_rate in integer  default null,
            p_select       in varchar2 default null,
            p_where        in varchar2 default null,
            p_group_by     in varchar2 default null,
            p_order_by     in varchar2 default null
            ) return moats_output_ntt pipelined is

      v_lower_snap pls_integer;
      v_upper_snap pls_integer;
      v_row        varchar2(4000);
      v_cnt        pls_integer := 0;

      -- DBMS_SQL variables...
      -- ---------------------
      v_sql        varchar2(32767);
      v_cursor     binary_integer;
      v_execute    integer;
      v_desc       dbms_sql.desc_tab2;
      v_cols       integer;
      v_value      varchar2(4000);

   begin

      -- Build up the dynamic SQL...
      -- ---------------------------
      v_sql := get_sql( p_select   => p_select,
                        p_from     => 'TABLE(moats.get_ash(:b1, :b2))',
                        p_where    => p_where,
                        p_group_by => p_group_by,
                        p_order_by => p_order_by );

      -- Open a cursor for the ASH queries, parse and describe it...
      -- -----------------------------------------------------------
      v_cursor := dbms_sql.open_cursor;
      dbms_sql.parse(v_cursor, v_sql, dbms_sql.native);
      dbms_sql.describe_columns2(v_cursor, v_cols, v_desc);

      -- Take some ASH samples...
      -- ------------------------
      poll( p_refresh_rate => p_refresh_rate,
            p_include_ash  => true,
            p_include_stat => false,
            p_include_hist => false,
            p_include_event => false,
            p_lower_snap   => v_lower_snap,
            p_upper_snap   => v_upper_snap );

      -- Bind the ASH snapshots...
      -- -------------------------
      dbms_sql.bind_variable(v_cursor, 'b1', v_lower_snap);
      dbms_sql.bind_variable(v_cursor, 'b2', v_upper_snap);

      -- Define the columns and variable we are fetching into...
      -- -------------------------------------------------------
      for i in 1 .. v_cols loop
         dbms_sql.define_column(v_cursor, i, v_value, 4000);
      end loop;

      -- Output the heading...
      -- ---------------------
      for i in 1 .. v_cols loop
         v_row := v_row || '|' || v_desc(i).col_name;
      end loop;
      pipe row (moats_output_ot(v_row));
      v_row := null;

      -- Start fetching...
      -- -----------------
      v_execute := dbms_sql.execute(v_cursor);

      while dbms_sql.fetch_rows(v_cursor) > 0 loop
         for i in 1 .. v_cols loop
            dbms_sql.column_value(v_cursor, i, v_value);
            v_row := v_row || '|' || v_value;
         end loop;
         pipe row (moats_output_ot(v_row));
         v_row := null;
      end loop;
      dbms_sql.close_cursor(v_cursor); --<-- will never be reached on an infinite loop with ctrl-c

      return;

   exception
      when others then
         dbms_sql.close_cursor(v_cursor);
         raise_application_error (-20000, 'Error: ' || sqlerrm || ' at:' || chr(10) || dbms_utility.format_error_backtrace, true);
   end ash;

   ----------------------------------------------------------------------------
   function get_ash (
            p_lower_snap in pls_integer default null,
            p_upper_snap in pls_integer default null,
            p_return_set in pls_integer default moats.gc_all_rows
            ) return moats_ash_ntt pipelined is
      v_lower_snap pls_integer := nvl(p_lower_snap, g_ash.first);
      v_upper_snap pls_integer := nvl(p_upper_snap, g_ash.last);
      v_snap       pls_integer;
      v_exit       boolean := false;
   begin
      v_snap := v_lower_snap;
      while v_snap is not null and not v_exit loop
         for i in 1 .. g_ash(v_snap).count loop
            -- Ignore dummy records
            if g_ash(v_snap)(i).sid is not null then
               pipe row (g_ash(v_snap)(i));
            end if;
         end loop;
         v_exit := (v_snap = v_upper_snap);
         v_snap := case p_return_set
                      when moats.gc_all_rows
                      then g_ash.next(v_snap)
                      else v_upper_snap
                   end;
      end loop;
      return;
   end get_ash;

begin
   restore_default_parameters();
end moats;
/
