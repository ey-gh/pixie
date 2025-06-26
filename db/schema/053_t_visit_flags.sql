-- ===========================
-- visit_flags
-- ===========================
create table visit_flags (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references clients(id) on delete cascade,
  service_date date not null,
  flag_type text not null, -- incident, refusal, no-show, etc.
  notes text,
  created_by uuid references users(id) on delete set null,
  created_at timestamptz default now()
);

create trigger trg_visit_flags_audit_log
after insert or update or delete on visit_flags
for each row execute function log_audit_event();

create index idx_visit_flags_client on visit_flags(client_id);
create index idx_visit_flags_date on visit_flags(service_date);
create index idx_visit_flags_type on visit_flags(flag_type);