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