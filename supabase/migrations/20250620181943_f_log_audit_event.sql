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