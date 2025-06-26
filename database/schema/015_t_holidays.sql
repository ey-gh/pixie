-- ========================================
-- HOLIDAYS (Optional)
-- ========================================
create table holidays (
  id uuid primary key default gen_random_uuid(),
  holiday_date date not null,
  name text not null,
  location_id uuid references locations(id) on delete cascade,
  is_active boolean default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  unique (holiday_date, location_id)
);

create trigger trg_holidays_set_updated_at
before update on holidays
for each row execute function set_updated_at();