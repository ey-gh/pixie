-- ===========================
-- audit_log (Immutable)
-- ===========================
create table audit_log (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references users(id) on delete set null,
  action text not null, -- 'insert', 'update', 'delete'
  table_name text not null,
  record_id uuid,
  changes jsonb,
  reason text,
  ip_address text,
  location_id uuid references locations(id) on delete set null,
  session_id uuid references login_sessions(id) on delete set null,
  created_at timestamptz default now()
);

create index idx_audit_log_user_id on audit_log(user_id);
create index idx_audit_log_table on audit_log(table_name);
create index idx_audit_log_record_id on audit_log(record_id);
create index idx_audit_log_action on audit_log(action);
create index idx_audit_log_created_at on audit_log(created_at);