-- autofill function to create attendance records for all active clients
create or replace function autofill_attendance_for_date(p_date date default current_date)
returns void
set search_path = ''
as $$
begin
  insert into attendance_log (
    client_id, service_date, status, created_at, updated_at
  )
  select
    cs.client_id,
    p_date,
    'present',
    now(),
    now()
  from client_schedule cs
  join clients c on cs.client_id = c.id
  where extract(dow from p_date) = cs.weekday
    and c.is_active = true
    and not exists (
      select 1 from attendance_log al
      where al.client_id = cs.client_id and al.service_date = p_date
    );
end;
$$ language plpgsql;