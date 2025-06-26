-- ===========================
-- attendance_log
-- ===========================
create table attendance_log (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references clients(id) on delete cascade,
  service_date date not null,
  status text default 'present', -- present, absent, hospitalized, excused
  check_in_time timestamptz,
  check_out_time timestamptz,
  recorded_by uuid references users(id) on delete set null,
  location_id uuid references locations(id) on delete set null,
  notes text,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  unique (client_id, service_date)
);

create trigger trg_attendance_log_set_updated_at
before update on attendance_log
for each row execute function set_updated_at();

create trigger trg_attendance_log_audit_log
after insert or update or delete on attendance_log
for each row execute function log_audit_event();

create index idx_attendance_log_client on attendance_log(client_id);
create index idx_attendance_log_date on attendance_log(service_date);
create index idx_attendance_log_status on attendance_log(status);