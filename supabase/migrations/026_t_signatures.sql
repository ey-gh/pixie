-- ===========================
-- signatures
-- ===========================
create table signatures (
  id uuid primary key default gen_random_uuid(),
  signer_id uuid references users(id) on delete set null,
  record_type text not null,
  record_id uuid not null,
  method text,
  signature_data jsonb,
  signed_at timestamptz default now(),
  created_at timestamptz default now()
);

create trigger trg_signatures_audit_log
after insert or update or delete on signatures
for each row execute function log_audit_event();

create index idx_signatures_record on signatures(record_type, record_id);
create index idx_signatures_signer on signatures(signer_id);