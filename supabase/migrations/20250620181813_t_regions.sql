-- ========================================
-- REGIONS (Optional)
-- ========================================
create table regions (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  description text,
  sort_order int default 0,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create trigger trg_regions_set_updated_at
before update on regions
for each row execute function set_updated_at();