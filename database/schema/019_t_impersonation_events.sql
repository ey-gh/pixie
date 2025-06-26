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