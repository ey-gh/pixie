-- ========================================
-- LOCATIONS
-- ========================================
create table locations (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid references organizations(id) on delete cascade,
  name text not null,
  address_street text,
  address_city text,
  address_state text,
  address_zip text,
  timezone text default 'America/New_York',
  is_active boolean default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create trigger trg_locations_set_updated_at
before update on locations
for each row execute function set_updated_at();

create index idx_locations_name on locations(name);