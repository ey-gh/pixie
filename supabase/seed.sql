-- locations
insert into locations (id, name, address_street, address_city, address_state, address_zip)
values
  ('00000000-0000-0000-0000-000000000001', 'Location1', '123 Test St', 'Testville', 'MA', '01001'),
  ('00000000-0000-0000-0000-000000000002', 'Location2', '456 Sample Blvd', 'Sampleton', 'MA', '02002'),
  ('00000000-0000-0000-0000-000000000003', 'Location3', '789 Demo Ave', 'Democity', 'MA', '03003');

-- roles
insert into roles (id, name, description)
values
  ('11111111-1111-1111-1111-111111111111', 'admin', 'Full access'),
  ('22222222-2222-2222-2222-222222222222', 'nurse', 'Clinical staff'),
  ('33333333-3333-3333-3333-333333333333', 'driver', 'Transport role');

-- users
insert into users (id, email, full_name, phone)
values
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'admin1@example.org', 'Admin One', '555-0001'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'nurse1@example.org', 'Nurse One', '555-0002'),
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'driver1@example.org', 'Driver One', '555-0003');

insert into user_roles (user_id, role_id)
values
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '22222222-2222-2222-2222-222222222222'),
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', '33333333-3333-3333-3333-333333333333');
