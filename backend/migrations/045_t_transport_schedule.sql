-- ===========================
-- transport_schedule
-- ===========================
create table transport_schedule (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references clients(id) on delete cascade,
  service_date date not null,
  request_am boolean default true,
  request_pm boolean default true,
  location_id uuid references locations(id) on delete set null,
  notes text,
  created_by uuid references users(id) on delete set null,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  unique (client_id, service_date)
);

create trigger trg_transport_schedule_set_updated_at
before update on transport_schedule
for each row execute function set_updated_at();

create trigger trg_transport_schedule_audit_log
after insert or update or delete on transport_schedule
for each row execute function log_audit_event();

create index idx_transport_schedule_client on transport_schedule(client_id);
create index idx_transport_schedule_date on transport_schedule(service_date);