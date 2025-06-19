-- ===========================
-- soft_delete_log
-- ===========================
create table soft_delete_log (
  id uuid primary key default gen_random_uuid(),
  table_name text not null,
  record_id uuid not null,
  deleted_by uuid references users(id) on delete set null,
  deleted_at timestamptz default now(),
  reason text
);

create trigger trg_soft_delete_log_audit_log
after insert or update or delete on soft_delete_log
for each row execute function log_audit_event();

create index idx_soft_delete_log_table on soft_delete_log(table_name);
create index idx_soft_delete_log_record on soft_delete_log(record_id);

-- ===========================
-- api_request_log
-- ===========================
create table api_request_log (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references users(id) on delete set null,
  endpoint text,
  method text, -- GET, POST, etc.
  request_payload jsonb,
  response_status int,
  response_body jsonb,
  ip_address text,
  duration_ms int,
  created_at timestamptz default now()
);

create trigger trg_api_request_log_audit_log
after insert or update or delete on api_request_log
for each row execute function log_audit_event();

create index idx_api_log_endpoint on api_request_log(endpoint);
create index idx_api_log_user on api_request_log(user_id);

-- ===========================
-- data_export_log
-- ===========================
create table data_export_log (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references users(id) on delete set null,
  export_type text, -- CSV, PDF, Excel
  record_type text,
  record_id uuid,
  file_id uuid references files(id) on delete set null,
  reason text,
  created_at timestamptz default now()
);

create trigger trg_data_export_log_audit_log
after insert or update or delete on data_export_log
for each row execute function log_audit_event();

create index idx_export_log_type on data_export_log(export_type);
create index idx_export_log_user on data_export_log(user_id);

-- ===========================
-- record_locks
-- ===========================
create table record_locks (
  id uuid primary key default gen_random_uuid(),
  record_type text not null,
  record_id uuid not null,
  locked_by uuid references users(id) on delete set null,
  locked_at timestamptz default now(),
  reason text,
  is_permanent boolean default false
);

create trigger trg_record_locks_audit_log
after insert or update or delete on record_locks
for each row execute function log_audit_event();

create index idx_record_locks_record on record_locks(record_type, record_id);

-- ===========================
-- document_templates
-- ===========================
create table document_templates (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  file_id uuid references files(id) on delete set null,
  document_type text, -- e.g. 'referral_form', 'nursing_eval'
  is_active boolean default true,
  created_by uuid references users(id) on delete set null,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create trigger trg_document_templates_set_updated_at
before update on document_templates
for each row execute function set_updated_at();

create trigger trg_document_templates_audit_log
after insert or update or delete on document_templates
for each row execute function log_audit_event();

create index idx_document_templates_type on document_templates(document_type);

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
