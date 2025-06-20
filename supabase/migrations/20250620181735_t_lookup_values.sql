-- ========================================
-- LOOKUP VALUES (Optional)
-- ========================================
create table lookup_values (
  id uuid primary key default gen_random_uuid(),
  category text not null, -- e.g. 'gender', 'ethnicity', 'language'
  code text not null,
  label text,
  sort_order int default 0,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  unique (category, code)
);

create trigger trg_lookup_values_set_updated_at
before update on lookup_values
for each row execute function set_updated_at();