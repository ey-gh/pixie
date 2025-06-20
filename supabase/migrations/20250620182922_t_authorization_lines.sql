-- ===========================
-- authorization_lines
-- ===========================
create table authorization_lines (
  id uuid primary key default gen_random_uuid(),
  authorization_id uuid not null references authorizations(id) on delete cascade,
  service_code text not null,     -- e.g. T2003, S5102
  service_description text,
  units int,
  unit_type text default 'per_day', -- per_day, per_visit, per_ride
  modifier text,                  -- optional CPT modifier
  frequency_limit int,           -- e.g. 2 visits/week
  notes text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create trigger trg_authorization_lines_set_updated_at
before update on authorization_lines
for each row execute function set_updated_at();

create trigger trg_authorization_lines_audit_log
after insert or update or delete on authorization_lines
for each row execute function log_audit_event();

create index idx_auth_lines_auth on authorization_lines(authorization_id);
create index idx_auth_lines_service on authorization_lines(service_code);