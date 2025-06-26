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