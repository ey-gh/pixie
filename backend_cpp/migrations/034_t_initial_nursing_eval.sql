-- ===========================
-- initial_nursing_eval
-- ===========================
create table initial_nursing_eval (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references clients(id) on delete cascade,
  eval_date date not null,
  diagnosis_summary text,
  vitals jsonb,
  nurse_id uuid references users(id) on delete set null,
  notes text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create trigger trg_nursing_eval_set_updated_at
before update on initial_nursing_eval
for each row execute function set_updated_at();

create trigger trg_nursing_eval_audit_log
after insert or update or delete on initial_nursing_eval
for each row execute function log_audit_event();

create index idx_nursing_eval_client on initial_nursing_eval(client_id);
