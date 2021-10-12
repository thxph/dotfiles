#!/usr/bin/env zsh

typeset -g histdb_file_local="${HOME}/.histdb/zsh-history.db"
typeset -g histdb_file_synced="${HOME}/rslsync/private/zsh/histdb/synced.db"

echo 'pragma wal_checkpoint(truncate);' | sqlite3 $histdb_file_local

sqlite3 -batch -noheader $histdb_file_local <<EOF

attach database '${histdb_file_synced}' as sync;

insert into commands (argv) select argv from sync.commands;
insert into places (host, dir) select host, dir from sync.places;

insert into sync.commands (argv) select argv from commands;
insert into sync.places (host, dir) select host, dir from places;

insert into history (session, command_id, place_id, exit_status, start_time, duration)
select ho.session, c.id, p.id, ho.exit_status, ho.start_time, ho.duration
from sync.history ho
left join sync.places po on ho.place_id = po.id
left join sync.commands co on ho.command_id = co.id
left join commands c on c.argv = co.argv
left join places p on (p.host = po.host
and p.dir = po.dir)
;

insert into sync.history (session, command_id, place_id, exit_status, start_time, duration)
select session, c.id, p.id, exit_status, start_time, duration
from history xo
left join places po on xo.place_id = po.id
left join commands co on xo.command_id = co.id
left join sync.commands c on c.argv = co.argv
left join sync.places p on (p.host = po.host
and p.dir = po.dir)
;

delete from history where id not in (select min(id) from history group by command_id,place_id,exit_status);
delete from sync.history where id not in (select min(id) from sync.history group by command_id,place_id,exit_status);

EOF
