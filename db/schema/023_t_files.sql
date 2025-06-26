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