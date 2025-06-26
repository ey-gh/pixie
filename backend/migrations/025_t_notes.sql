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