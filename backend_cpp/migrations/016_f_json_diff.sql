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