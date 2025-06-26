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
