-- ===========================
-- payer_rules
-- ===========================
create table payer_rules (
  id uuid primary key default gen_random_uuid(),
  payer_id uuid not null references payers(id) on delete cascade,
  service_code text not null,
  modifier text,
  unit_limit int,
  frequency text, -- daily, weekly, monthly, per_visit
  conditions jsonb,
  notes text,
  effective_date date,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create trigger trg_payer_rules_set_updated_at
before update on payer_rules
for each row execute function set_updated_at();

create trigger trg_payer_rules_audit_log
after insert or update or delete on payer_rules
for each row execute function log_audit_event();

create index idx_payer_rules_payer on payer_rules(payer_id);
create index idx_payer_rules_service on payer_rules(service_code);