-- ===========================
-- insurance_providers
-- ===========================
create table insurance_providers (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  type text, -- 'SCO', 'OneCare', 'Medicare', etc.
  npi text,
  is_active boolean default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create trigger trg_insurance_providers_set_updated_at
before update on insurance_providers
for each row execute function set_updated_at();

create index idx_insurance_providers_type on insurance_providers(type);

-- ===========================
-- payers (updated)
-- ===========================
create table payers (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  type text,              -- e.g. 'intermediary', 'sco', 'medicare', 'fiscal_agent'
  npi text,               -- if applicable
  contact_name text,
  contact_phone text,
  contact_email text,
  is_active boolean default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create trigger trg_payers_set_updated_at
before update on payers
for each row execute function set_updated_at();

create index idx_payers_type on payers(type);
create index idx_payers_name on payers(name);

-- ===========================
-- provider-payer relationships
-- ===========================
create table insurance_provider_payers (
  id uuid primary key default gen_random_uuid(),
  insurance_provider_id uuid not null references insurance_providers(id) on delete cascade,
  payer_id uuid not null references payers(id) on delete cascade,
  plan_name text, -- optional, e.g. 'OneCare Plan A'
  is_default boolean default false,
  effective_date date,
  expiration_date date,
  notes text,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  unique (insurance_provider_id, payer_id, plan_name)
);

create trigger trg_insurance_provider_payers_set_updated_at
before update on insurance_provider_payers
for each row execute function set_updated_at();

create trigger trg_insurance_provider_payers_audit_log
after insert or update or delete on insurance_provider_payers
for each row execute function log_audit_event();

create index idx_ip_payers_provider on insurance_provider_payers(insurance_provider_id);
create index idx_ip_payers_payer on insurance_provider_payers(payer_id);
create index idx_ip_payers_default on insurance_provider_payers(is_default);

-- ===========================
-- authorizations (updated)
-- ===========================
create table authorizations (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references clients(id) on delete cascade,

  insurance_provider_id uuid not null references insurance_providers(id),
  payer_id uuid references payers(id), -- now optional

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

-- Leave existing triggers
create trigger trg_authorizations_set_updated_at
before update on authorizations
for each row execute function set_updated_at();

create trigger trg_authorizations_audit_log
after insert or update or delete on authorizations
for each row execute function log_audit_event();

-- Add relevant indexes
create index idx_authorizations_client on authorizations(client_id);
create index idx_authorizations_provider on authorizations(insurance_provider_id);
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
declare
  rule record;
  payer_id uuid;
begin
  select a.payer_id into payer_id
  from authorizations a
  where a.id = new.authorization_id;

  select * into rule
  from payer_rules
  where payer_id = payer_id
    and service_code = new.service_code
    and (modifier is null or modifier = new.modifier)
    and (effective_date is null or effective_date <= current_date)
  order by effective_date desc
  limit 1;

  if rule.unit_limit is not null and new.units > rule.unit_limit then
    raise exception 'Units (% units) exceed payer limit (% units) for service %',
      new.units, rule.unit_limit, new.service_code;
  end if;

  return new;
end;
$$ language plpgsql;