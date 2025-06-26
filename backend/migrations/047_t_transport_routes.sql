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