-- ===========================
-- files
-- ===========================
create table files (
  id uuid primary key default gen_random_uuid(),
  filename text not null,
  content_type text,
  file_size int,
  storage_path text not null,
  uploaded_by uuid references users(id) on delete set null,
  checksum text,
  is_deleted boolean default false,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create trigger trg_files_set_updated_at
before update on files
for each row execute function set_updated_at();

create trigger trg_files_audit_log
after insert or update or delete on files
for each row execute function log_audit_event();

create index idx_files_filename on files(filename);
create index idx_files_uploaded_by on files(uploaded_by);

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

-- ===========================
-- notes
-- ===========================
create table notes (
  id uuid primary key default gen_random_uuid(),
  record_type text not null,
  record_id uuid not null,
  author_id uuid references users(id) on delete set null,
  body text not null,
  is_pinned boolean default false,
  is_private boolean default false,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create trigger trg_notes_set_updated_at
before update on notes
for each row execute function set_updated_at();

create trigger trg_notes_audit_log
after insert or update or delete on notes
for each row execute function log_audit_event();

create index idx_notes_record on notes(record_type, record_id);
create index idx_notes_author on notes(author_id);

-- ===========================
-- signatures
-- ===========================
create table signatures (
  id uuid primary key default gen_random_uuid(),
  signer_id uuid references users(id) on delete set null,
  record_type text not null,
  record_id uuid not null,
  method text,
  signature_data jsonb,
  signed_at timestamptz default now(),
  created_at timestamptz default now()
);

create trigger trg_signatures_audit_log
after insert or update or delete on signatures
for each row execute function log_audit_event();

create index idx_signatures_record on signatures(record_type, record_id);
create index idx_signatures_signer on signatures(signer_id);

-- ===========================
-- tags
-- ===========================
create table tags (
  id uuid primary key default gen_random_uuid(),
  record_type text not null,
  record_id uuid not null,
  tag text not null,
  tagged_by uuid references users(id) on delete set null,
  created_at timestamptz default now()
);

create trigger trg_tags_audit_log
after insert or update or delete on tags
for each row execute function log_audit_event();

create index idx_tags_record on tags(record_type, record_id);
create index idx_tags_tag on tags(tag);
