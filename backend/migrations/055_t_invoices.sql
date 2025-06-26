-- ===========================
-- invoices
-- ===========================
create table invoices (
  id uuid primary key default gen_random_uuid(),
  invoice_number text unique,
  invoice_date date default current_date,
  payer_id uuid references payers(id) on delete set null,
  location_id uuid references locations(id) on delete set null,
  status text default 'open', -- open, submitted, closed
  batch_ref text,
  notes text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create trigger trg_invoices_set_updated_at
before update on invoices
for each row execute function set_updated_at();

create trigger trg_invoices_audit_log
after insert or update or delete on invoices
for each row execute function log_audit_event();

create index idx_invoices_date on invoices(invoice_date);
create index idx_invoices_status on invoices(status);