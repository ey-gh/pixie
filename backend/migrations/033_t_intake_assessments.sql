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