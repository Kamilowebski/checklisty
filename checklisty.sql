-- Checklisty procedur: tabele, prywatny bucket na zdjęcia i RLS
-- Wklej w Supabase: SQL Editor -> New query -> Run

-- Procedury (szablony). kroki: [{ "id", "tekst", "zdjecia": ["<user_id>/<uuid>.jpg"] }]
create table if not exists public.procedury (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  tytul text not null check (char_length(tytul) between 1 and 200),
  opis text not null default '',
  kroki jsonb not null default '[]',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Wykonania (historia). kroki: [{ "id", "tekst", "zrobione", "zdjecia": [...], "wzor": [...] }]
-- procedura_id bez klucza obcego: po usunięciu procedury historia zostaje.
create table if not exists public.wykonania (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  procedura_id uuid,
  tytul text not null,
  kroki jsonb not null default '[]',
  notatka text not null default '',
  status text not null default 'w_toku' check (status in ('w_toku', 'zakonczone')),
  created_at timestamptz not null default now(),
  finished_at timestamptz
);

create index if not exists procedury_user_idx on public.procedury (user_id, created_at desc);
create index if not exists wykonania_user_idx on public.wykonania (user_id, created_at desc);

alter table public.procedury enable row level security;
alter table public.wykonania enable row level security;

drop policy if exists "own procedury" on public.procedury;
create policy "own procedury" on public.procedury
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists "own wykonania" on public.wykonania;
create policy "own wykonania" on public.wykonania
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

-- Prywatny bucket na zdjęcia (limit 5 MB na plik, tylko obrazy)
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('checklisty-zdjecia', 'checklisty-zdjecia', false, 5242880, array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do nothing;

-- Dostęp do zdjęć tylko we własnym folderze: <user_id>/...
drop policy if exists "checklisty zdjecia select" on storage.objects;
create policy "checklisty zdjecia select" on storage.objects for select to authenticated
  using (bucket_id = 'checklisty-zdjecia' and (storage.foldername(name))[1] = auth.uid()::text);

drop policy if exists "checklisty zdjecia insert" on storage.objects;
create policy "checklisty zdjecia insert" on storage.objects for insert to authenticated
  with check (bucket_id = 'checklisty-zdjecia' and (storage.foldername(name))[1] = auth.uid()::text);

drop policy if exists "checklisty zdjecia delete" on storage.objects;
create policy "checklisty zdjecia delete" on storage.objects for delete to authenticated
  using (bucket_id = 'checklisty-zdjecia' and (storage.foldername(name))[1] = auth.uid()::text);
