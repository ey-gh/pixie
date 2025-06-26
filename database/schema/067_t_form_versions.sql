-- ===========================
-- form_versions
-- ===========================
create table form_versions (
  id uuid primary key default gen_random_uuid(),
  form_name text not null,
  version_number int not null,
  schema_json jsonb not null,
  notes text,
  is_active boolean default true,
  created_by uuid references users(id) on delete set null,
  created_at timestamptz default now()
);

create trigger trg_form_versions_audit_log
after insert or update or delete on form_versions
for each row execute function log_audit_event();

create index idx_form_versions_name on form_versions(form_name);
create index idx_form_versions_version on form_versions(version_number);