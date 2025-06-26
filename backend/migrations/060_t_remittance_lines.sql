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