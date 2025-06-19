-- ===========================
-- invoices
-- ===========================
create table invoices (
  id uuid primary key default gen_random_uuid(),
  invoice_number text unique,
  invoice_date date default current_date,
  payer_id uuid references payers(id) on delete set null,
  location_id uuid references locations(id) on delete set null,
  status text default 'open', -- open, submitted, closed
  batch_ref text,
  notes text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create trigger trg_invoices_set_updated_at
before update on invoices
for each row execute function set_updated_at();

create trigger trg_invoices_audit_log
after insert or update or delete on invoices
for each row execute function log_audit_event();

create index idx_invoices_date on invoices(invoice_date);
create index idx_invoices_status on invoices(status);

-- ===========================
-- claims
-- ===========================
create table claims (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references clients(id) on delete cascade,
  invoice_id uuid references invoices(id) on delete set null,
  authorization_id uuid references authorizations(id) on delete set null,
  service_date date not null,
  location_id uuid references locations(id) on delete set null,
  status text not null default 'pending', -- pending, submitted, paid, denied
  submitted_at timestamptz,
  created_by uuid references users(id) on delete set null,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create trigger trg_claims_set_updated_at
before update on claims
for each row execute function set_updated_at();

create trigger trg_claims_audit_log
after insert or update or delete on claims
for each row execute function log_audit_event();

create index idx_claims_client on claims(client_id);
create index idx_claims_status on claims(status);
create index idx_claims_date on claims(service_date);

-- ===========================
-- claim_lines
-- ===========================
create table claim_lines (
  id uuid primary key default gen_random_uuid(),
  claim_id uuid not null references claims(id) on delete cascade,
  service_code text not null,      -- CPT/HCPCS code
  modifier text,
  units int not null,
  rate numeric(10,2),
  total_amount numeric(10,2) generated always as (units * rate) stored,
  notes text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create trigger trg_claim_lines_set_updated_at
before update on claim_lines
for each row execute function set_updated_at();

create trigger trg_claim_lines_audit_log
after insert or update or delete on claim_lines
for each row execute function log_audit_event();

create index idx_claim_lines_claim on claim_lines(claim_id);
create index idx_claim_lines_service on claim_lines(service_code);

-- ===========================
-- claim_flags
-- ===========================
create table claim_flags (
  id uuid primary key default gen_random_uuid(),
  claim_id uuid not null references claims(id) on delete cascade,
  flag_type text not null, -- 'overbilling', 'gap', 'date_mismatch', etc.
  flagged_by uuid references users(id) on delete set null,
  notes text,
  created_at timestamptz default now()
);

create trigger trg_claim_flags_audit_log
after insert or update or delete on claim_flags
for each row execute function log_audit_event();

create index idx_claim_flags_claim on claim_flags(claim_id);
create index idx_claim_flags_type on claim_flags(flag_type);

-- ===========================
-- remittances
-- ===========================
create table remittances (
  id uuid primary key default gen_random_uuid(),
  remittance_date date not null,
  payer_id uuid references payers(id) on delete set null,
  payment_reference text,
  payment_amount numeric(12,2),
  method text, -- EFT, check, wire
  status text default 'received',
  notes text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create trigger trg_remittances_set_updated_at
before update on remittances
for each row execute function set_updated_at();

create trigger trg_remittances_audit_log
after insert or update or delete on remittances
for each row execute function log_audit_event();

create index idx_remittances_date on remittances(remittance_date);
create index idx_remittances_status on remittances(status);

-- ===========================
-- remittance_lines
-- ===========================
create table remittance_lines (
  id uuid primary key default gen_random_uuid(),
  remittance_id uuid not null references remittances(id) on delete cascade,
  claim_id uuid references claims(id) on delete set null,
  service_code text,
  adjudicated_amount numeric(10,2),
  adjustment_reason text,
  notes text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create trigger trg_remittance_lines_set_updated_at
before update on remittance_lines
for each row execute function set_updated_at();

create trigger trg_remittance_lines_audit_log
after insert or update or delete on remittance_lines
for each row execute function log_audit_event();

create index idx_remittance_lines_remittance on remittance_lines(remittance_id);
create index idx_remittance_lines_claim on remittance_lines(claim_id);

-- ===========================
-- denials
-- ===========================
create table denials (
  id uuid primary key default gen_random_uuid(),
  claim_id uuid not null references claims(id) on delete cascade,
  denial_reason text,
  denied_by text,
  denial_date date default current_date,
  appeal_submitted boolean default false,
  appeal_notes text,
  resolved boolean default false,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create trigger trg_denials_set_updated_at
before update on denials
for each row execute function set_updated_at();

create trigger trg_denials_audit_log
after insert or update or delete on denials
for each row execute function log_audit_event();

create index idx_denials_claim on denials(claim_id);
create index idx_denials_reason on denials(denial_reason);
