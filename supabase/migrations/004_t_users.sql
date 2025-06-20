-- ========================================
-- USERS
-- ========================================
create table users (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid references organizations(id) on delete cascade,
  email text not null unique,
  full_name text,
  phone text,
  is_active boolean default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create trigger trg_users_set_updated_at
before update on users
for each row execute function set_updated_at();

create index idx_users_email on users(email);
