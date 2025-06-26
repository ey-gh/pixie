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