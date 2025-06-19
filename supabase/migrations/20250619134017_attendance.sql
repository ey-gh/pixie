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

-- ===========================
-- inbound_log
-- ===========================
create table inbound_log (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references clients(id) on delete cascade,
  service_date date not null,
  driver_id uuid references users(id) on delete set null,
  vehicle_id uuid references transport_vehicles(id) on delete set null,
  pickup_time timestamptz,
  location_id uuid references locations(id) on delete set null,
  notes text,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  unique (client_id, service_date)
);

create trigger trg_inbound_log_set_updated_at
before update on inbound_log
for each row execute function set_updated_at();

create trigger trg_inbound_log_audit_log
after insert or update or delete on inbound_log
for each row execute function log_audit_event();

create index idx_inbound_log_date on inbound_log(service_date);
create index idx_inbound_log_driver on inbound_log(driver_id);

-- ===========================
-- outbound_log
-- ===========================
create table outbound_log (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references clients(id) on delete cascade,
  service_date date not null,
  driver_id uuid references users(id) on delete set null,
  vehicle_id uuid references transport_vehicles(id) on delete set null,
  dropoff_time timestamptz,
  location_id uuid references locations(id) on delete set null,
  notes text,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  unique (client_id, service_date)
);

create trigger trg_outbound_log_set_updated_at
before update on outbound_log
for each row execute function set_updated_at();

create trigger trg_outbound_log_audit_log
after insert or update or delete on outbound_log
for each row execute function log_audit_event();

create index idx_outbound_log_date on outbound_log(service_date);
create index idx_outbound_log_driver on outbound_log(driver_id);

-- ===========================
-- visit_flags
-- ===========================
create table visit_flags (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references clients(id) on delete cascade,
  service_date date not null,
  flag_type text not null, -- incident, refusal, no-show, etc.
  notes text,
  created_by uuid references users(id) on delete set null,
  created_at timestamptz default now()
);

create trigger trg_visit_flags_audit_log
after insert or update or delete on visit_flags
for each row execute function log_audit_event();

create index idx_visit_flags_client on visit_flags(client_id);
create index idx_visit_flags_date on visit_flags(service_date);
create index idx_visit_flags_type on visit_flags(flag_type);

-- Add to end of attendance.sql
create or replace function autofill_attendance_for_date(p_date date default current_date)
returns void as $$
... [as provided above] ...
$$ language plpgsql;
