-- ========================================
-- SETTINGS (Key-Value)
-- ========================================
create table settings (
  id uuid primary key default gen_random_uuid(),
  key text not null,
  value jsonb not null,
  scope text default 'global', -- 'global', 'org', 'location'
  org_id uuid references organizations(id) on delete cascade,
  location_id uuid references locations(id) on delete cascade,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  unique (key, scope, org_id, location_id)
);

create trigger trg_settings_set_updated_at
before update on settings
for each row execute function set_updated_at();