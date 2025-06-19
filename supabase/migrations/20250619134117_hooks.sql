-- ===========================
-- workflow_triggers
-- ===========================
create table workflow_triggers (
  id uuid primary key default gen_random_uuid(),
  trigger_name text not null,
  module_name text not null, -- e.g. 'authorizations'
  condition jsonb not null,  -- e.g. {"field":"end_date", "lt_days":7}
  action_type text not null, -- 'flag', 'notify', 'assign_task'
  action_payload jsonb,
  is_active boolean default true,
  created_by uuid references users(id) on delete set null,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create trigger trg_workflow_triggers_set_updated_at
before update on workflow_triggers
for each row execute function set_updated_at();

create trigger trg_workflow_triggers_audit_log
after insert or update or delete on workflow_triggers
for each row execute function log_audit_event();

create index idx_workflow_triggers_module on workflow_triggers(module_name);

-- ===========================
-- notifications
-- ===========================
create table notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references users(id) on delete cascade,
  message text not null,
  is_read boolean default false,
  delivery_method text default 'internal', -- internal, email, sms
  related_record_type text,
  related_record_id uuid,
  created_at timestamptz default now(),
  read_at timestamptz
);

create trigger trg_notifications_audit_log
after insert or update or delete on notifications
for each row execute function log_audit_event();

create index idx_notifications_user on notifications(user_id);
create index idx_notifications_read on notifications(is_read);

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

-- ===========================
-- cron_log
-- ===========================
create table cron_log (
  id uuid primary key default gen_random_uuid(),
  job_name text not null,
  run_started timestamptz default now(),
  run_ended timestamptz,
  status text, -- success, fail
  log_output text,
  error_message text,
  created_at timestamptz default now()
);

create trigger trg_cron_log_audit_log
after insert or update or delete on cron_log
for each row execute function log_audit_event();

create index idx_cron_log_job on cron_log(job_name);
create index idx_cron_log_status on cron_log(status);
