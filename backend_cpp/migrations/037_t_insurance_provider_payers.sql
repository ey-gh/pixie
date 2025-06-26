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