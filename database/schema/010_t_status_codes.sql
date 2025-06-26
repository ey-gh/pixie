-- ========================================
-- STATUS CODES (ENUM-LIKE)
-- ========================================
create table status_codes (
  id uuid primary key default gen_random_uuid(),
  category text not null, -- e.g. 'referral_status', 'client_status'
  code text not null,
  label text not null,
  description text,
  is_active boolean default true,
  sort_order int default 0,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  unique (category, code)
);

create trigger trg_status_codes_set_updated_at
before update on status_codes
for each row execute function set_updated_at();

create index idx_status_codes_category on status_codes(category);