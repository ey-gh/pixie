-- ===========================
-- client_flags
-- ===========================
create table client_flags (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references clients(id) on delete cascade,
  flag_type text not null, -- 'behavioral', 'medical', etc.
  label text not null,
  notes text,
  is_active boolean default true,
  created_by uuid references users(id) on delete set null,
  created_at timestamptz default now()
);

create trigger trg_client_flags_audit_log
after insert or update or delete on client_flags
for each row execute function log_audit_event();

create index idx_client_flags_client on client_flags(client_id);
create index idx_client_flags_type on client_flags(flag_type);