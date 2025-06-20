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