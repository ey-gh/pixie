-- ===========================
-- attendance_status_log
-- ===========================
create table attendance_status_log (
  id uuid primary key default gen_random_uuid(),
  attendance_id uuid not null references attendance_log(id) on delete cascade,
  old_status text,
  new_status text,
  changed_at timestamptz default now(),
  changed_by uuid references users(id) on delete set null,
  reason text
);

create trigger trg_attendance_status_log_audit_log
after insert or update or delete on attendance_status_log
for each row execute function log_audit_event();

create index idx_status_log_attendance on attendance_status_log(attendance_id);
create index idx_status_log_new_status on attendance_status_log(new_status);