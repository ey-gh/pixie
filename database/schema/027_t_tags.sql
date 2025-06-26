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