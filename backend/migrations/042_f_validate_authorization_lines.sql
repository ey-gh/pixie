create or replace function validate_authorization_line()
returns trigger 
set search_path = ''
as $$
declare
  rule record;
  payer_id uuid;
begin
  select a.payer_id into payer_id
  from authorizations a
  where a.id = new.authorization_id;

  select * into rule
  from payer_rules
  where payer_id = payer_id
    and service_code = new.service_code
    and (modifier is null or modifier = new.modifier)
    and (effective_date is null or effective_date <= current_date)
  order by effective_date desc
  limit 1;

  if rule.unit_limit is not null and new.units > rule.unit_limit then
    raise exception 'Units (% units) exceed payer limit (% units) for service %',
      new.units, rule.unit_limit, new.service_code;
  end if;

  return new;
end;
$$ language plpgsql;