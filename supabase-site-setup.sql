-- Run ONCE in Supabase > SQL editor (same project as the app).
-- STEP 1: change the email below to the email of your Supabase admin user.
create or replace function public.is_site_admin() returns boolean language sql stable as $$
  select coalesce(auth.jwt()->>'email','') = any (array['CHANGE_ME@example.com'])
$$;

-- Q&A questions
create table if not exists public.questions(id bigint generated always as identity primary key,created_at timestamptz default now(),name text,kind text default 'Question',question text not null check(char_length(question) between 8 and 1000),answer text,answered boolean default false);
alter table public.questions enable row level security;
drop policy if exists "anyone can ask" on public.questions;
create policy "anyone can ask" on public.questions for insert to anon with check (answered=false and answer is null);
drop policy if exists "anyone can read answered" on public.questions;
create policy "anyone can read answered" on public.questions for select to anon using (answered=true);
drop policy if exists "admin manages questions" on public.questions;
create policy "admin manages questions" on public.questions for all to authenticated using (public.is_site_admin()) with check (public.is_site_admin());

-- Visitor analytics
create table if not exists public.site_visits(id bigint generated always as identity primary key,created_at timestamptz default now(),vid text,path text,ref text,device text,w int,tz text,lang text,utm text,is_new boolean default false);
create index if not exists site_visits_created_idx on public.site_visits(created_at desc);
alter table public.site_visits enable row level security;
drop policy if exists "anyone can log a visit" on public.site_visits;
create policy "anyone can log a visit" on public.site_visits for insert to anon, authenticated with check (true);
drop policy if exists "admin reads visits" on public.site_visits;
create policy "admin reads visits" on public.site_visits for select to authenticated using (public.is_site_admin());

-- Photos (gallery, tournaments, about)
create table if not exists public.site_photos(id bigint generated always as identity primary key,created_at timestamptz default now(),area text not null check (area in ('gallery','tournaments','about')),caption text,url text not null,path text);
alter table public.site_photos enable row level security;
drop policy if exists "anyone can view photos" on public.site_photos;
create policy "anyone can view photos" on public.site_photos for select to anon, authenticated using (true);
drop policy if exists "admin manages photos" on public.site_photos;
create policy "admin manages photos" on public.site_photos for all to authenticated using (public.is_site_admin()) with check (public.is_site_admin());

-- Blog posts
create table if not exists public.posts(id bigint generated always as identity primary key,created_at timestamptz default now(),slug text unique not null,title text not null,excerpt text,body text,cover_url text,published boolean default true);
alter table public.posts enable row level security;
drop policy if exists "anyone can read published posts" on public.posts;
create policy "anyone can read published posts" on public.posts for select to anon, authenticated using (published);
drop policy if exists "admin manages posts" on public.posts;
create policy "admin manages posts" on public.posts for all to authenticated using (public.is_site_admin()) with check (public.is_site_admin());

-- Image storage
insert into storage.buckets(id,name,public) values('site-media','site-media',true) on conflict (id) do nothing;
drop policy if exists "admin uploads site media" on storage.objects;
create policy "admin uploads site media" on storage.objects for insert to authenticated with check (bucket_id='site-media' and public.is_site_admin());
drop policy if exists "admin updates site media" on storage.objects;
create policy "admin updates site media" on storage.objects for update to authenticated using (bucket_id='site-media' and public.is_site_admin());
drop policy if exists "admin deletes site media" on storage.objects;
create policy "admin deletes site media" on storage.objects for delete to authenticated using (bucket_id='site-media' and public.is_site_admin());
