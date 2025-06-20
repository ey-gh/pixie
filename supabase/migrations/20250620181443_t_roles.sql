-- ========================================
-- ROLES
-- ========================================
create table roles (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  description text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create trigger trg_roles_set_updated_at
before update on roles
for each row execute function set_updated_at();