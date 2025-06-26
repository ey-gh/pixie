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