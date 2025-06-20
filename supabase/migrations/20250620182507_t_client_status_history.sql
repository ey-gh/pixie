-- ===========================
-- client_status_history
-- ===========================
create table client_status_history (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references clients(id) on delete cascade,
  status_code text not null, -- foreign key alternative from status_codes
  reason text,
  effective_date date not null,
  recorded_by uuid references users(id) on delete set null,
  created_at timestamptz default now()
);

create trigger trg_client_status_history_audit_log
after insert or update or delete on client_status_history
for each row execute function log_audit_event();

create index idx_status_history_client on client_status_history(client_id);
create index idx_status_history_date on client_status_history(effective_date);