-- append.io initial schema
-- Run via: supabase db push   (or paste into the Supabase SQL editor)

-- Plaid items: one row per linked institution. The access_token is the
-- sensitive credential — clients can list their connections but the
-- column grant below keeps the token readable only by the service role.
create table public.plaid_items (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  item_id text not null unique,
  access_token text not null,
  institution_id text,
  institution_name text,
  created_at timestamptz not null default now()
);

create table public.accounts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  item_id uuid not null references public.plaid_items (id) on delete cascade,
  plaid_account_id text not null unique,
  name text not null,
  institution_name text,
  type text,
  subtype text,
  mask text,
  balance numeric not null default 0,
  updated_at timestamptz not null default now()
);

create table public.holdings (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  account_id uuid not null references public.accounts (id) on delete cascade,
  plaid_security_id text not null,
  ticker text,
  name text,
  quantity numeric not null default 0,
  price numeric not null default 0,
  value numeric not null default 0,
  cost_basis numeric,
  updated_at timestamptz not null default now(),
  unique (account_id, plaid_security_id)
);

-- Row level security: users only ever see their own rows.
alter table public.plaid_items enable row level security;
alter table public.accounts enable row level security;
alter table public.holdings enable row level security;

create policy "own plaid_items" on public.plaid_items
  for select using (auth.uid() = user_id);

create policy "own accounts" on public.accounts
  for select using (auth.uid() = user_id);

create policy "own holdings" on public.holdings
  for select using (auth.uid() = user_id);

-- Clients may list their connections but never read access tokens:
revoke select on public.plaid_items from anon, authenticated;
grant select (id, user_id, item_id, institution_id, institution_name, created_at)
  on public.plaid_items to authenticated;

-- Writes happen exclusively through edge functions using the service role.
