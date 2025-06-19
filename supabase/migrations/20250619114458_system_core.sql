-- EXTENSION
create extension if not exists "pgcrypto";

-- TRIGGER FUNCTION (for updated_at)
create or replace function set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

-- ========================================
-- USERS
-- ========================================
create table users (
  id uuid primary key default gen_random_uuid(),
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

-- ========================================
-- PERMISSIONS (Optional Granular)
-- ========================================
create table permissions (
  id uuid primary key default gen_random_uuid(),
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

-- ========================================
-- LOCATIONS
-- ========================================
create table locations (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  address_street text,
  address_city text,
  address_state text,
  address_zip text,
  timezone text default 'America/New_York',
  is_active boolean default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create trigger trg_locations_set_updated_at
before update on locations
for each row execute function set_updated_at();

create index idx_locations_name on locations(name);

-- ========================================
-- ORGANIZATIONS
-- ========================================
create table organizations (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  tax_id text,
  npi text,
  website text,
  is_active boolean default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create trigger trg_organizations_set_updated_at
before update on organizations
for each row execute function set_updated_at();

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

-- ========================================
-- STATUS CODES (ENUM-LIKE)
-- ========================================
create table status_codes (
  id uuid primary key default gen_random_uuid(),
  category text not null, -- e.g. 'referral_status', 'client_status'
  code text not null,
  label text not null,
  description text,
  is_active boolean default true,
  sort_order int default 0,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  unique (category, code)
);

create trigger trg_status_codes_set_updated_at
before update on status_codes
for each row execute function set_updated_at();

create index idx_status_codes_category on status_codes(category);

-- ========================================
-- TAG REGISTRY (Optional)
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

-- ========================================
-- REGIONS (Optional)
-- ========================================
create table regions (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  description text,
  sort_order int default 0,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create trigger trg_regions_set_updated_at
before update on regions
for each row execute function set_updated_at();

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
