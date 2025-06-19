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

-- ===========================
-- client_identifiers
-- ===========================
create table client_identifiers (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references clients(id) on delete cascade,
  identifier_type text not null, -- 'ssn', 'masshealth', 'internal'
  identifier_value text not null,
  is_primary boolean default false,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  unique (identifier_type, identifier_value)
);

create trigger trg_client_identifiers_set_updated_at
before update on client_identifiers
for each row execute function set_updated_at();

create trigger trg_client_identifiers_audit_log
after insert or update or delete on client_identifiers
for each row execute function log_audit_event();

create index idx_client_identifiers_client on client_identifiers(client_id);
create index idx_client_identifiers_type on client_identifiers(identifier_type);

-- ===========================
-- client_status_history
-- ===========================
create table client_status_history (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references clients(id) on delete cascade,
  status_code text not null, -- foreign key alternative from status_codes
  reason text,
  effective_date date not null,
  recorded_by uuid references users(id) on delete set null,
  created_at timestamptz default now()
);

create trigger trg_client_status_history_audit_log
after insert or update or delete on client_status_history
for each row execute function log_audit_event();

create index idx_status_history_client on client_status_history(client_id);
create index idx_status_history_date on client_status_history(effective_date);

-- ===========================
-- client_flags
-- ===========================
create table client_flags (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references clients(id) on delete cascade,
  flag_type text not null, -- 'behavioral', 'medical', etc.
  label text not null,
  notes text,
  is_active boolean default true,
  created_by uuid references users(id) on delete set null,
  created_at timestamptz default now()
);

create trigger trg_client_flags_audit_log
after insert or update or delete on client_flags
for each row execute function log_audit_event();

create index idx_client_flags_client on client_flags(client_id);
create index idx_client_flags_type on client_flags(flag_type);

-- ===========================
-- referrals
-- ===========================
create table referrals (
  id uuid primary key default gen_random_uuid(),
  client_id uuid references clients(id) on delete cascade,
  referral_source text,
  referral_contact text,
  referral_date date,
  status text,
  referred_by uuid references users(id) on delete set null,
  notes text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create trigger trg_referrals_set_updated_at
before update on referrals
for each row execute function set_updated_at();

create trigger trg_referrals_audit_log
after insert or update or delete on referrals
for each row execute function log_audit_event();

create index idx_referrals_client on referrals(client_id);
create index idx_referrals_status on referrals(status);

-- ===========================
-- intake_assessments
-- ===========================
create table intake_assessments (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references clients(id) on delete cascade,
  assessment_date date not null,
  adl_score int,
  iadl_score int,
  social_eval text,
  psych_eval text,
  evaluator_id uuid references users(id) on delete set null,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create trigger trg_intake_assessments_set_updated_at
before update on intake_assessments
for each row execute function set_updated_at();

create trigger trg_intake_assessments_audit_log
after insert or update or delete on intake_assessments
for each row execute function log_audit_event();

create index idx_intake_assessments_client on intake_assessments(client_id);

-- ===========================
-- initial_nursing_eval
-- ===========================
create table initial_nursing_eval (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references clients(id) on delete cascade,
  eval_date date not null,
  diagnosis_summary text,
  vitals jsonb,
  nurse_id uuid references users(id) on delete set null,
  notes text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create trigger trg_nursing_eval_set_updated_at
before update on initial_nursing_eval
for each row execute function set_updated_at();

create trigger trg_nursing_eval_audit_log
after insert or update or delete on initial_nursing_eval
for each row execute function log_audit_event();

create index idx_nursing_eval_client on initial_nursing_eval(client_id);
