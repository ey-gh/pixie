-- ========================================
-- ORGANIZATIONS
-- ========================================
create table organizations (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  tax_id text,
  npi text,
  website text,
  is_active boolean default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create trigger trg_organizations_set_updated_at
before update on organizations
for each row execute function set_updated_at();