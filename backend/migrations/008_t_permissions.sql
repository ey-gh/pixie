-- ========================================
-- PERMISSIONS (Optional Granular)
-- ========================================
create table permissions (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid references organizations(id) on delete cascade,
  role_id uuid references roles(id) on delete cascade,
  module_name text not null,
  action text not null, -- e.g. 'view', 'edit', 'delete'
  location_id uuid references locations(id),
  field_scope jsonb,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  unique (role_id, module_name, action, location_id)
);

create trigger trg_permissions_set_updated_at
before update on permissions
for each row execute function set_updated_at();