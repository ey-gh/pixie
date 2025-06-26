-- ========================================
-- TIMEZONES (Optional)
-- ========================================
create table timezones (
  id uuid primary key default gen_random_uuid(),
  name text not null unique, -- e.g. "America/New_York"
  offset_minutes int,
  is_active boolean default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create trigger trg_timezones_set_updated_at
before update on timezones
for each row execute function set_updated_at();