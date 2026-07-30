create table if not exists public.todos (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  is_complete boolean not null default false,
  inserted_at timestamptz not null default now()
);

alter table public.todos enable row level security;

drop policy if exists "Todos are readable by everyone" on public.todos;
create policy "Todos are readable by everyone"
on public.todos
for select
using (true);

insert into public.todos (id, title, is_complete)
values
  ('00000000-0000-0000-0000-000000000001', 'Enter the Nix shell with direnv', true),
  ('00000000-0000-0000-0000-000000000002', 'Start Supabase and Vite with pnpm', false),
  ('00000000-0000-0000-0000-000000000003', 'Open Supabase Studio locally', false)
on conflict (id) do nothing;
