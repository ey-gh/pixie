-- ===========================
-- tasks
-- ===========================
create table tasks (
  id uuid primary key default gen_random_uuid(),
  assigned_to uuid references users(id) on delete set null,
  assigned_by uuid references users(id) on delete set null,
  status text default 'open', -- open, in_progress, complete, cancelled
  due_date date,
  module_name text,
  record_type text,
  record_id uuid,
  description text,
  resolution_notes text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create trigger trg_tasks_set_updated_at
before update on tasks
for each row execute function set_updated_at();

create trigger trg_tasks_audit_log
after insert or update or delete on tasks
for each row execute function log_audit_event();

create index idx_tasks_assigned_to on tasks(assigned_to);
create index idx_tasks_status on tasks(status);
create index idx_tasks_due on tasks(due_date);