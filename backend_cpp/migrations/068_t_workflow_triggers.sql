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