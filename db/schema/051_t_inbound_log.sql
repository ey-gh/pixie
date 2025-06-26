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