-- ===========================
-- authorizations
-- ===========================
create table authorizations (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references clients(id) on delete cascade,
  payer_id uuid not null references payers(id) on delete cascade,
  authorization_number text,
  start_date date not null,
  end_date date not null,
  status text not null default 'pending', -- approved, denied, expired
  notes text,
  created_by uuid references users(id) on delete set null,
  updated_by uuid references users(id) on delete set null,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create trigger trg_authorizations_set_updated_at
before update on authorizations
for each row execute function set_updated_at();

create trigger trg_authorizations_audit_log
after insert or update or delete on authorizations
for each row execute function log_audit_event();

create index idx_authorizations_client on authorizations(client_id);
create index idx_authorizations_payer on authorizations(payer_id);
create index idx_authorizations_status on authorizations(status);

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

-- ===========================
-- authorization_audit
-- ===========================
create table authorization_audit (
  id uuid primary key default gen_random_uuid(),
  authorization_id uuid not null references authorizations(id) on delete cascade,
  change_date timestamptz default now(),
  old_status text,
  new_status text,
  changed_by uuid references users(id) on delete set null,
  reason text
);

create trigger trg_authorization_audit_log
after insert or update or delete on authorization_audit
for each row execute function log_audit_event();

create index idx_auth_audit_auth on authorization_audit(authorization_id);
create index idx_auth_audit_status on authorization_audit(new_status);

-- ===========================
-- payer_rules
-- ===========================
create table payer_rules (
  id uuid primary key default gen_random_uuid(),
  payer_id uuid not null references payers(id) on delete cascade,
  service_code text not null,
  modifier text,
  unit_limit int,
  frequency text, -- daily, weekly, monthly, per_visit
  conditions jsonb,
  notes text,
  effective_date date,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create trigger trg_payer_rules_set_updated_at
before update on payer_rules
for each row execute function set_updated_at();

create trigger trg_payer_rules_audit_log
after insert or update or delete on payer_rules
for each row execute function log_audit_event();

create index idx_payer_rules_payer on payer_rules(payer_id);
create index idx_payer_rules_service on payer_rules(service_code);

-- Add to end of authorization.sql
create or replace function validate_authorization_line()
returns trigger as $$
... [as provided above] ...
$$ language plpgsql;

create trigger trg_validate_authorization_line
before insert or update on authorization_lines
for each row execute function validate_authorization_line();
