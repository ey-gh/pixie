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