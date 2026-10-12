-- Run ONLY in a NEW dedicated AUREON INVEST AI Supabase project.
create table public.profiles(user_id uuid primary key references auth.users(id) on delete cascade,display_name text,created_at timestamptz not null default now());
create table public.holdings(id uuid primary key default gen_random_uuid(),user_id uuid not null references auth.users(id) on delete cascade,ticker text not null check(ticker ~ '^[A-Z0-9]{4,12}$'),quantity numeric(24,8) not null check(quantity>0),average_price numeric(24,8) not null check(average_price>0),created_at timestamptz not null default now());
create table public.user_settings(user_id uuid primary key references auth.users(id) on delete cascade,monthly_budget numeric(20,2) not null default 0 check(monthly_budget>=0),risk_profile text not null default 'nao_definido' check(risk_profile in ('nao_definido','conservador','moderado','arrojado')),automatic_orders_enabled boolean not null default false check(automatic_orders_enabled=false));
create table public.signals(id uuid primary key default gen_random_uuid(),ticker text not null,score integer not null check(score between 0 and 100),classification text not null check(classification in ('OBSERVAR','AGUARDAR','EVITAR')),rationale text not null,source_timestamp timestamptz,created_at timestamptz not null default now());
alter table public.profiles enable row level security;
alter table public.holdings enable row level security;
alter table public.user_settings enable row level security;
alter table public.signals enable row level security;
create policy profiles_read on public.profiles for select to authenticated using ((select auth.uid())=user_id);
create policy profiles_insert on public.profiles for insert to authenticated with check ((select auth.uid())=user_id);
create policy profiles_update on public.profiles for update to authenticated using ((select auth.uid())=user_id) with check ((select auth.uid())=user_id);
create policy holdings_read on public.holdings for select to authenticated using ((select auth.uid())=user_id);
create policy holdings_insert on public.holdings for insert to authenticated with check ((select auth.uid())=user_id);
create policy holdings_update on public.holdings for update to authenticated using ((select auth.uid())=user_id) with check ((select auth.uid())=user_id);
create policy holdings_delete on public.holdings for delete to authenticated using ((select auth.uid())=user_id);
create policy settings_read on public.user_settings for select to authenticated using ((select auth.uid())=user_id);
create policy settings_insert on public.user_settings for insert to authenticated with check ((select auth.uid())=user_id);
create policy settings_update on public.user_settings for update to authenticated using ((select auth.uid())=user_id) with check ((select auth.uid())=user_id);
create policy signals_read on public.signals for select to authenticated using(true);
-- No client-side writes to signals; no orders or brokerage integrations in phase 1.
