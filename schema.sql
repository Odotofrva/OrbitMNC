-- Run in Supabase SQL Editor. Enable email confirmation and restrict signups to your team.
create table if not exists public.profiles (
 id uuid primary key references auth.users(id) on delete cascade,
 display_name text not null default 'New crew member',
 avatar_index integer not null default 0 check (avatar_index between 0 and 5),
 created_at timestamptz not null default now()
);
create table if not exists public.tasks (
 id uuid primary key default gen_random_uuid(),
 title text not null check (char_length(title) between 1 and 140),
 notes text not null default '',
 due_date date,
 priority text not null default 'Normal' check (priority in ('Low','Normal','High')),
 completed boolean not null default false,
 assignee_id uuid references public.profiles(id) on delete set null,
 created_by uuid not null references public.profiles(id) on delete cascade,
 created_at timestamptz not null default now()
);
create table if not exists public.team_members (
 user_id uuid primary key references auth.users(id) on delete cascade,
 created_at timestamptz not null default now()
);
-- Restrict the team by adding approved user IDs to team_members via the SQL editor.
create or replace function public.is_team_member() returns boolean language sql stable security definer set search_path=public as $$
 select exists(select 1 from public.team_members where user_id=(select auth.uid()));
$$;
create or replace function public.create_profile_for_user() returns trigger language plpgsql security definer set search_path=public as $$
begin
 insert into public.profiles(id,display_name,avatar_index) values(new.id,split_part(new.email,'@',1),floor(random()*6)::integer)
 on conflict (id) do nothing;
 return new;
end;$$;
drop trigger if exists on_auth_user_created_orbit on auth.users;
create trigger on_auth_user_created_orbit after insert on auth.users for each row execute procedure public.create_profile_for_user();
alter table public.profiles enable row level security;
alter table public.tasks enable row level security;
alter table public.team_members enable row level security;
drop policy if exists "Team reads profiles" on public.profiles;
create policy "Team reads profiles" on public.profiles for select to authenticated using (public.is_team_member());
drop policy if exists "Team updates own profile" on public.profiles;
create policy "Team updates own profile" on public.profiles for update to authenticated using (public.is_team_member() and id=(select auth.uid())) with check (public.is_team_member() and id=(select auth.uid()));
drop policy if exists "Team reads tasks" on public.tasks;
create policy "Team reads tasks" on public.tasks for select to authenticated using (public.is_team_member());
drop policy if exists "Team inserts tasks" on public.tasks;
create policy "Team inserts tasks" on public.tasks for insert to authenticated with check (public.is_team_member() and created_by=(select auth.uid()));
drop policy if exists "Team updates tasks" on public.tasks;
create policy "Team updates tasks" on public.tasks for update to authenticated using (public.is_team_member()) with check (public.is_team_member());
drop policy if exists "Team deletes tasks" on public.tasks;
create policy "Team deletes tasks" on public.tasks for delete to authenticated using (public.is_team_member());
-- Intentionally no client-facing policies on team_members. Approvals are admin-only.
