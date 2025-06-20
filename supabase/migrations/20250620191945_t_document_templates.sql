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