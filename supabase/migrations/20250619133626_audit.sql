-- ===========================
-- EXTENSION
-- ===========================
create extension if not exists "pgcrypto";

-- ===========================
-- GLOBAL FUNCTION: json_diff
-- ===========================
create or replace function json_diff(old_row jsonb, new_row jsonb)
returns jsonb
set search_path = ''
as $$
declare
  result jsonb := '{}';
  key text;
begin
  for key in select jsonb_object_keys(new_row)
  loop
    if old_row -> key is distinct from new_row -> key then
      result := result || jsonb_build_object(key, json_build_object(
        'old', old_row -> key,
        'new', new_row -> key
      ));
    end if;
  end loop;
  return result;
end;
$$ language plpgsql;

-- ===========================
-- GLOBAL FUNCTION: log_audit_event
-- ===========================
create or replace function log_audit_event()
returns trigger
set search_path = ''
as $$
declare
  change_data jsonb;
begin
  if (TG_OP = 'DELETE') then
    change_data := to_jsonb(OLD);
  elsif (TG_OP = 'INSERT') then
    change_data := to_jsonb(NEW);
  else
    change_data := json_diff(to_jsonb(OLD), to_jsonb(NEW));
  end if;

  insert into public.audit_log (
    user_id,
    action,
    table_name,
    record_id,
    changes,
    ip_address,
    location_id,
    session_id,
    created_at
  ) values (
    current_setting('app.current_user_id', true)::uuid,
    TG_OP,
    TG_TABLE_NAME,
    coalesce(NEW.id, OLD.id),
    change_data,
    current_setting('app.current_ip', true),
    current_setting('app.current_location_id', true)::uuid,
    current_setting('app.current_session_id', true)::uuid,
    now()
  );

  return null;
end;
$$ language plpgsql;

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

-- ===========================
-- impersonation_events
-- ===========================
create table impersonation_events (
  id uuid primary key default gen_random_uuid(),
  admin_user_id uuid not null references users(id) on delete cascade,
  impersonated_user_id uuid not null references users(id) on delete cascade,
  reason text,
  started_at timestamptz default now(),
  ended_at timestamptz,
  ip_address text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create trigger trg_impersonation_events_set_updated_at
before update on impersonation_events
for each row execute function set_updated_at();

create index idx_impersonation_events_admin on impersonation_events(admin_user_id);
create index idx_impersonation_events_target on impersonation_events(impersonated_user_id);

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

-- ===========================
-- activity_log
-- ===========================
create table activity_log (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references users(id) on delete set null,
  action text not null, -- e.g. 'click', 'form_submit'
  target text,          -- e.g. 'client_intake', 'authorization_edit'
  target_id uuid,
  location_id uuid references locations(id) on delete set null,
  metadata jsonb,
  created_at timestamptz default now()
);

create index idx_activity_log_user_id on activity_log(user_id);
create index idx_activity_log_action on activity_log(action);
create index idx_activity_log_created_at on activity_log(created_at);

-- ===========================
-- audit_log (Immutable)
-- ===========================
create table audit_log (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references users(id) on delete set null,
  action text not null, -- 'insert', 'update', 'delete'
  table_name text not null,
  record_id uuid,
  changes jsonb,
  reason text,
  ip_address text,
  location_id uuid references locations(id) on delete set null,
  session_id uuid references login_sessions(id) on delete set null,
  created_at timestamptz default now()
);

create index idx_audit_log_user_id on audit_log(user_id);
create index idx_audit_log_table on audit_log(table_name);
create index idx_audit_log_record_id on audit_log(record_id);
create index idx_audit_log_action on audit_log(action);
create index idx_audit_log_created_at on audit_log(created_at);
