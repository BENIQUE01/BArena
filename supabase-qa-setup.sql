-- Run once in Supabase > SQL editor
create table public.questions(id bigint generated always as identity primary key,created_at timestamptz default now(),name text,kind text default 'Question',question text not null check(char_length(question) between 8 and 1000),answer text,answered boolean default false);
alter table public.questions enable row level security;
create policy "anyone can ask" on public.questions for insert to anon with check (answered=false and answer is null);
create policy "anyone can read answered" on public.questions for select to anon using (answered=true);
-- To reply: open Table editor > questions, fill "answer", tick "answered".
