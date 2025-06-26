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