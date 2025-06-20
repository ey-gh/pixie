-- ===========================
-- authorizations (updated)
-- ===========================
create table authorizations (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references clients(id) on delete cascade,

  insurance_provider_id uuid not null references insurance_providers(id),
  payer_id uuid references payers(id), -- now optional

  authorization_number text,
  start_date date not null,
  end_date date not null,
  status text not null default 'pending', -- approved, denied, expired
  notes text,
  created_by uuid references users(id) on delete set null,
  updated_by uuid references users(id) on delete set null,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Leave existing triggers
create trigger trg_authorizations_set_updated_at
before update on authorizations
for each row execute function set_updated_at();

create trigger trg_authorizations_audit_log
after insert or update or delete on authorizations
for each row execute function log_audit_event();

-- Add relevant indexes
create index idx_authorizations_client on authorizations(client_id);
create index idx_authorizations_provider on authorizations(insurance_provider_id);
create index idx_authorizations_payer on authorizations(payer_id);
create index idx_authorizations_status on authorizations(status);
