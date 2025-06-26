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