-- ===========================
-- authorization_audit
-- ===========================
create table authorization_audit (
  id uuid primary key default gen_random_uuid(),
  authorization_id uuid not null references authorizations(id) on delete cascade,
  change_date timestamptz default now(),
  old_status text,
  new_status text,
  changed_by uuid references users(id) on delete set null,
  reason text
);

create trigger trg_authorization_audit_log
after insert or update or delete on authorization_audit
for each row execute function log_audit_event();

create index idx_auth_audit_auth on authorization_audit(authorization_id);
create index idx_auth_audit_status on authorization_audit(new_status);