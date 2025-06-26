-- ===========================
-- referrals
-- ===========================
create table referrals (
  id uuid primary key default gen_random_uuid(),
  client_id uuid references clients(id) on delete cascade,
  referral_source text,
  referral_contact text,
  referral_date date,
  status text,
  referred_by uuid references users(id) on delete set null,
  notes text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create trigger trg_referrals_set_updated_at
before update on referrals
for each row execute function set_updated_at();

create trigger trg_referrals_audit_log
after insert or update or delete on referrals
for each row execute function log_audit_event();

create index idx_referrals_client on referrals(client_id);
create index idx_referrals_status on referrals(status);