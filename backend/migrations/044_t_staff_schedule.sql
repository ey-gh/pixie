-- ===========================
-- staff_schedule
-- ===========================
create table staff_schedule (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references users(id) on delete cascade,
  location_id uuid references locations(id) on delete set null,
  shift_date date not null,
  role text not null, -- e.g. 'driver', 'rn', 'aide'
  notes text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create trigger trg_staff_schedule_set_updated_at
before update on staff_schedule
for each row execute function set_updated_at();

create trigger trg_staff_schedule_audit_log
after insert or update or delete on staff_schedule
for each row execute function log_audit_event();

create index idx_staff_schedule_user on staff_schedule(user_id);
create index idx_staff_schedule_date on staff_schedule(shift_date);