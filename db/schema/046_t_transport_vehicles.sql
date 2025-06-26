-- ===========================
-- transport_vehicles
-- ===========================
create table transport_vehicles (
  id uuid primary key default gen_random_uuid(),
  license_plate text not null unique,
  vehicle_type text, -- 'van', 'sedan', 'wheelchair-accessible'
  capacity int,
  is_active boolean default true,
  notes text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create trigger trg_transport_vehicles_set_updated_at
before update on transport_vehicles
for each row execute function set_updated_at();

create trigger trg_transport_vehicles_audit_log
after insert or update or delete on transport_vehicles
for each row execute function log_audit_event();