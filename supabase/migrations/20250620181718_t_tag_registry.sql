-- ========================================
-- TAG REGISTRY
-- ========================================
create table tag_registry (
  id uuid primary key default gen_random_uuid(),
  category text not null, -- e.g. 'client', 'claim', etc.
  tag text not null,
  color text,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  unique (category, tag)
);

create trigger trg_tag_registry_set_updated_at
before update on tag_registry
for each row execute function set_updated_at();