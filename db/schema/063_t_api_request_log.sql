-- ===========================
-- api_request_log
-- ===========================
create table api_request_log (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references users(id) on delete set null,
  endpoint text,
  method text, -- GET, POST, etc.
  request_payload jsonb,
  response_status int,
  response_body jsonb,
  ip_address text,
  duration_ms int,
  created_at timestamptz default now()
);

create trigger trg_api_request_log_audit_log
after insert or update or delete on api_request_log
for each row execute function log_audit_event();

create index idx_api_log_endpoint on api_request_log(endpoint);
create index idx_api_log_user on api_request_log(user_id);
