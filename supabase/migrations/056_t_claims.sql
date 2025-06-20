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