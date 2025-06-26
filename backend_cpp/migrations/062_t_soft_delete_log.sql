-- ===========================
-- soft_delete_log
-- ===========================
create table soft_delete_log (
  id uuid primary key default gen_random_uuid(),
  table_name text not null,
  record_id uuid not null,
  deleted_by uuid references users(id) on delete set null,
  deleted_at timestamptz default now(),
  reason text
);

create trigger trg_soft_delete_log_audit_log
after insert or update or delete on soft_delete_log
for each row execute function log_audit_event();

create index idx_soft_delete_log_table on soft_delete_log(table_name);
create index idx_soft_delete_log_record on soft_delete_log(record_id);