-- ===========================
-- record_locks
-- ===========================
create table record_locks (
  id uuid primary key default gen_random_uuid(),
  record_type text not null,
  record_id uuid not null,
  locked_by uuid references users(id) on delete set null,
  locked_at timestamptz default now(),
  reason text,
  is_permanent boolean default false
);

create trigger trg_record_locks_audit_log
after insert or update or delete on record_locks
for each row execute function log_audit_event();

create index idx_record_locks_record on record_locks(record_type, record_id);