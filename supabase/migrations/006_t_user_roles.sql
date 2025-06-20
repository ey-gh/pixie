-- ========================================
-- USER ROLES (M:N)
-- ========================================
create table user_roles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references users(id) on delete cascade,
  role_id uuid not null references roles(id) on delete cascade,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  unique (user_id, role_id)
);

create trigger trg_user_roles_set_updated_at
before update on user_roles
for each row execute function set_updated_at();

create index idx_user_roles_user_id on user_roles(user_id);
create index idx_user_roles_role_id on user_roles(role_id);