-- ===========================
-- login_sessions
-- ===========================
create table login_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references users(id) on delete cascade,
  issued_at timestamptz default now(),
  expires_at timestamptz,
  user_agent text,
  ip_address text,
  is_revoked boolean default false,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create trigger trg_login_sessions_set_updated_at
before update on login_sessions
for each row execute function set_updated_at();

create index idx_login_sessions_user_id on login_sessions(user_id);
create index idx_login_sessions_issued_at on login_sessions(issued_at);