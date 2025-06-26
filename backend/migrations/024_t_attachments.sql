-- ===========================
-- attachments
-- ===========================
create table attachments (
  id uuid primary key default gen_random_uuid(),
  file_id uuid not null references files(id) on delete cascade,
  record_type text not null,
  record_id uuid not null,
  attached_by uuid references users(id) on delete set null,
  description text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create trigger trg_attachments_set_updated_at
before update on attachments
for each row execute function set_updated_at();

create trigger trg_attachments_audit_log
after insert or update or delete on attachments
for each row execute function log_audit_event();

create index idx_attachments_file_id on attachments(file_id);
create index idx_attachments_record on attachments(record_type, record_id);