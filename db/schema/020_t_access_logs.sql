-- ===========================
-- access_logs
-- ===========================
create table access_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references users(id) on delete set null,
  event_type text not null, -- 'login', 'logout', etc.
  ip_address text,
  user_agent text,
  session_id uuid references login_sessions(id) on delete set null,
  metadata jsonb,
  created_at timestamptz default now()
);

create index idx_access_logs_user_id on access_logs(user_id);
create index idx_access_logs_event_type on access_logs(event_type);
create index idx_access_logs_created_at on access_logs(created_at);