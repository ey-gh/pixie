-- ===========================
-- data_export_log
-- ===========================
create table data_export_log (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references users(id) on delete set null,
  export_type text, -- CSV, PDF, Excel
  record_type text,
  record_id uuid,
  file_id uuid references files(id) on delete set null,
  reason text,
  created_at timestamptz default now()
);

create trigger trg_data_export_log_audit_log
after insert or update or delete on data_export_log
for each row execute function log_audit_event();

create index idx_export_log_type on data_export_log(export_type);
create index idx_export_log_user on data_export_log(user_id);