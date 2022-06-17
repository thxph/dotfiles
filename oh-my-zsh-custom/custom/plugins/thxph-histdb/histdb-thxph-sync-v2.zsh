#!/usr/bin/env zsh

typeset -g histdb_file_local="${HOME}/.histdb/zsh-history.db"
typeset -g histdb_file_synced="${HOME}/rslsync/private/zsh/histdb/synced.db"

echo 'pragma wal_checkpoint(truncate);' | sqlite3 $histdb_file_local >/dev/null

echo 'select local_cmd_id, remote_cmd_id, local_plc_id, remote_plc_id, local_hist_id, remote_hist_id from thxph_sync_status' \
    | sqlite3 $histdb_file_local >/dev/null 2>&1

if [ ! $? -eq  0 ]; then
    echo Cannot query sync status table, please run sync-init script
    exit
fi

sqlite3 -batch -noheader $histdb_file_local <<EOF

attach database '${histdb_file_synced}' as sync;

begin;

update thxph_sync_status set local_cmd_id = (select max(id) from commands) where id = 1;
update thxph_sync_status set local_plc_id = (select max(id) from places) where id = 1;
update thxph_sync_status set local_hist_id = (select max(id) from history) where id = 1;
update thxph_sync_status set remote_cmd_id = (select max(id) from sync.commands) where id = 1;
update thxph_sync_status set remote_plc_id = (select max(id) from sync.places) where id = 1;
update thxph_sync_status set remote_hist_id = (select max(id) from sync.history) where id = 1;

insert into commands (argv) select argv from sync.commands where
    id      > (select remote_cmd_id from thxph_sync_status order by id desc limit 1)
    and id <= (select remote_cmd_id from thxph_sync_status where id = 1);
select 'Synced ' || changes() || ' cmds from remote to local db';

insert into places (host, dir) select host, dir from sync.places where
    id      > (select remote_plc_id from thxph_sync_status order by id desc limit 1)
    and id <= (select remote_plc_id from thxph_sync_status where id = 1);
select 'Synced ' || changes() || ' dirs from remote to local db';

insert into sync.commands (argv) select argv from commands where
    id      > (select local_cmd_id from thxph_sync_status order by id desc limit 1)
    and id <= (select local_cmd_id from thxph_sync_status where id = 1);
select 'Synced ' || changes() || ' cmds from local to remote db';

insert into sync.places (host, dir) select host, dir from places where
    id      > (select local_plc_id from thxph_sync_status order by id desc limit 1)
    and id <= (select local_plc_id from thxph_sync_status where id = 1);
select 'Synced ' || changes() || ' dirs from local to remote db';

insert into history (session, command_id, place_id, exit_status, start_time, duration)
select ho.session, c.id, p.id, ho.exit_status, ho.start_time, ho.duration
from sync.history ho
left join sync.places po on ho.place_id = po.id
left join sync.commands co on ho.command_id = co.id
left join commands c on c.argv = co.argv
left join places p on (p.host = po.host
and p.dir = po.dir)
where
    ho.id      > (select remote_hist_id from thxph_sync_status order by id desc limit 1)
    and ho.id <= (select remote_hist_id from thxph_sync_status where id = 1)
;
select 'Synced ' || changes() || ' history entries from remote to local';

insert into sync.history (session, command_id, place_id, exit_status, start_time, duration)
select session, c.id, p.id, exit_status, start_time, duration
from history xo
left join places po on xo.place_id = po.id
left join commands co on xo.command_id = co.id
left join sync.commands c on c.argv = co.argv
left join sync.places p on (p.host = po.host
and p.dir = po.dir)
where
    xo.id      > (select local_hist_id from thxph_sync_status order by id desc limit 1)
    and xo.id <= (select local_hist_id from thxph_sync_status where id = 1)
;
select 'Synced ' || changes() || ' history entries from local to remote';

select 'Cleaning up data...';
update thxph_sync_status set local_cmd_id = (select max(id) from commands) where id = 1;
update thxph_sync_status set local_plc_id = (select max(id) from places) where id = 1;
update thxph_sync_status set local_hist_id = (select max(id) from history) where id = 1;
update thxph_sync_status set remote_cmd_id = (select max(id) from sync.commands) where id = 1;
update thxph_sync_status set remote_plc_id = (select max(id) from sync.places) where id = 1;
update thxph_sync_status set remote_hist_id = (select max(id) from sync.history) where id = 1;

INSERT INTO thxph_sync_status(sync_ts,local_cmd_id,remote_cmd_id,local_plc_id,remote_plc_id,local_hist_id,remote_hist_id)
               select sync_ts,local_cmd_id,remote_cmd_id,local_plc_id,remote_plc_id,local_hist_id,remote_hist_id from thxph_sync_status where id = 1;
update thxph_sync_status set sync_ts=STRFTIME('%s') where id = (select max(id) from thxph_sync_status);

delete from history where id not in (select max(id) from history group by command_id,place_id,exit_status);
select 'Deleted ' || changes() || ' duplicated entries from local history';
delete from sync.history where id not in (select max(id) from sync.history group by command_id,place_id,exit_status);
select 'Deleted ' || changes() || ' duplicated entries from remote history';

end;

EOF

echo 'vacuum;' | sqlite3 $histdb_file_local
echo 'vacuum;' | sqlite3 $histdb_file_synced

