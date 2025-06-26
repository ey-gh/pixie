-- ===========================
-- clients
-- ===========================
create table clients (
  id uuid primary key default gen_random_uuid(),
  first_name text not null,
  last_name text not null,
  dob date,
  gender text check (gender in ('male', 'female', 'other', 'undisclosed')),
  phone text,
  email text unique,
  address_street text,
  address_city text,
  address_state text,
  address_zip text,
  preferred_language text,
  ethnicity text,
  is_active boolean default true,
  created_by uuid references users(id) on delete set null,
  updated_by uuid references users(id) on delete set null,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create trigger trg_clients_set_updated_at
before update on clients
for each row execute function set_updated_at();

create trigger trg_clients_audit_log
after insert or update or delete on clients
for each row execute function log_audit_event();

create index idx_clients_last_name on clients(last_name);
create index idx_clients_zip on clients(address_zip);
