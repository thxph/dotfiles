#!/usr/bin/env zsh

typeset -g histdb_file_local="${HOME}/.histdb/zsh-history.db"

echo 'pragma wal_checkpoint(truncate);' | sqlite3 $histdb_file_local >>/dev/null

sqlite3 -batch -noheader $histdb_file_local <<EOF

drop table if exists thxph_sync_status;
create table thxph_sync_status(id integer primary key autoincrement, sync_ts int, local_cmd_id int, remote_cmd_id, local_plc_id, remote_plc_id, local_hist_id, remote_hist_id);
INSERT INTO thxph_sync_status(sync_ts,local_cmd_id,remote_cmd_id,local_plc_id,remote_plc_id,local_hist_id,remote_hist_id)
SELECT 0, 0, 0, 0, 0, 0, 0;
INSERT INTO thxph_sync_status(sync_ts,local_cmd_id,remote_cmd_id,local_plc_id,remote_plc_id,local_hist_id,remote_hist_id)
SELECT STRFTIME('%s'), 0, 0, 0, 0, 0, 0;

EOF

echo 'vacuum;' | sqlite3 $histdb_file_local
