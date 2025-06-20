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