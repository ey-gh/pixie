-- ===========================
-- client_schedule
-- ===========================
create table client_schedule (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references clients(id) on delete cascade,
  weekday smallint not null check (weekday between 0 and 6), -- 0 = Sunday
  is_transport_needed boolean default true,
  location_id uuid references locations(id) on delete set null,
  notes text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create trigger trg_client_schedule_set_updated_at
before update on client_schedule
for each row execute function set_updated_at();

create trigger trg_client_schedule_audit_log
after insert or update or delete on client_schedule
for each row execute function log_audit_event();

create index idx_client_schedule_client on client_schedule(client_id);
create index idx_client_schedule_weekday on client_schedule(weekday);

-- ===========================
-- staff_schedule
-- ===========================
create table staff_schedule (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references users(id) on delete cascade,
  location_id uuid references locations(id) on delete set null,
  shift_date date not null,
  role text not null, -- e.g. 'driver', 'rn', 'aide'
  notes text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create trigger trg_staff_schedule_set_updated_at
before update on staff_schedule
for each row execute function set_updated_at();

create trigger trg_staff_schedule_audit_log
after insert or update or delete on staff_schedule
for each row execute function log_audit_event();

create index idx_staff_schedule_user on staff_schedule(user_id);
create index idx_staff_schedule_date on staff_schedule(shift_date);

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

-- ===========================
-- transport_routes
-- ===========================
create table transport_routes (
  id uuid primary key default gen_random_uuid(),
  route_name text not null,
  region text, -- ZIP prefix, city, or grouping logic
  location_id uuid references locations(id) on delete set null,
  is_active boolean default true,
  notes text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create trigger trg_transport_routes_set_updated_at
before update on transport_routes
for each row execute function set_updated_at();

create trigger trg_transport_routes_audit_log
after insert or update or delete on transport_routes
for each row execute function log_audit_event();

create index idx_transport_routes_name on transport_routes(route_name);

-- ===========================
-- routing_events
-- ===========================
create table routing_events (
  id uuid primary key default gen_random_uuid(),
  event_type text not null, -- 'manual', 'auto-generated'
  service_date date not null,
  location_id uuid references locations(id) on delete set null,
  vehicle_id uuid references transport_vehicles(id) on delete set null,
  route_id uuid references transport_routes(id) on delete set null,
  metadata jsonb,
  created_by uuid references users(id) on delete set null,
  created_at timestamptz default now()
);

create trigger trg_routing_events_audit_log
after insert or update or delete on routing_events
for each row execute function log_audit_event();

create index idx_routing_events_date on routing_events(service_date);
create index idx_routing_events_type on routing_events(event_type);
