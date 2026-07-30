insert into public.todos (id, title, is_complete)
values
  ('00000000-0000-0000-0000-000000000001', 'Enter the Nix shell with direnv', true),
  ('00000000-0000-0000-0000-000000000002', 'Start Supabase and Vite with pnpm', false),
  ('00000000-0000-0000-0000-000000000003', 'Open Supabase Studio locally', false)
on conflict (id) do nothing;
