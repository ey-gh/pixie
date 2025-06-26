-- ===========================
-- client_identifiers
-- ===========================
create table client_identifiers (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references clients(id) on delete cascade,
  identifier_type text not null, -- 'ssn', 'masshealth', 'internal'
  identifier_value text not null,
  is_primary boolean default false,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  unique (identifier_type, identifier_value)
);

create trigger trg_client_identifiers_set_updated_at
before update on client_identifiers
for each row execute function set_updated_at();

create trigger trg_client_identifiers_audit_log
after insert or update or delete on client_identifiers
for each row execute function log_audit_event();

create index idx_client_identifiers_client on client_identifiers(client_id);
create index idx_client_identifiers_type on client_identifiers(identifier_type);
