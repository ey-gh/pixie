-- ===========================
-- payers (updated)
-- ===========================
create table payers (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  type text,              -- e.g. 'intermediary', 'sco', 'medicare', 'fiscal_agent'
  npi text,               -- if applicable
  contact_name text,
  contact_phone text,
  contact_email text,
  is_active boolean default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create trigger trg_payers_set_updated_at
before update on payers
for each row execute function set_updated_at();

create index idx_payers_type on payers(type);
create index idx_payers_name on payers(name);