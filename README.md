# Checklisty procedur

Procedury krok po kroku z odhaczaniem i zdjęciami. Tworzysz procedurę (szablon) z krokami i zdjęciami wzorcowymi, a potem uruchamiasz ją jako wykonanie: odhaczasz kroki, dodajesz własne zdjęcia (np. z telefonu) i notatkę. Historia wykonań zostaje w bazie. Jeden plik statyczny (`index.html`, Tailwind przez CDN), działa na GitHub Pages. Dane są w Supabase (logowanie e-mail + hasło), zdjęcia w prywatnym buckecie Supabase Storage.

Adres: https://kamilowebski.github.io/checklisty/

## Funkcje

- procedury: tytuł, opis, kroki z kolejnością (w górę/w dół), do 8 zdjęć na krok
- wykonania: odhaczanie kroków, pasek postępu, zdjęcia dokumentujące, notatka (zapis automatyczny), zakończenie i wznowienie
- zdjęcia z aparatu lub galerii telefonu, zmniejszane w przeglądarce do 1600 px (JPEG) przed wysłaniem
- podgląd zdjęć w powiększeniu, zdjęcia wzorcowe widoczne podczas wykonania
- wyszukiwanie oraz filtr statusu (w toku / zakończone)

## Pliki

| Plik | Opis |
| --- | --- |
| `index.html` | cała aplikacja (HTML, Tailwind przez CDN, JS) |
| `checklisty.sql` | tabele `procedury` i `wykonania`, bucket na zdjęcia i RLS |
| `manifest.webmanifest` | manifest PWA (nazwa, kolory, ikony) |
| `icons/` | favicon, ikona Apple Touch, ikony 192/512 i maskable |

## Uruchomienie

1. W Supabase: SQL Editor → wklej `checklisty.sql` → Run (tworzy tabele, bucket `checklisty-zdjecia` i polityki).
2. W `index.html` sprawdź `SB_URL` i `SB_KEY` na górze skryptu (klucz publishable, nie `service_role`).
3. Wrzuć zawartość repozytorium na GitHub Pages (gałąź `main`, katalog główny).
4. Konta zakładasz ręcznie: Authentication → Users → Add user (zaznacz Auto Confirm User).
5. Dopisz stronę do listy `APPS` w `hub/apps.js` (id `checklisty`, ścieżka `checklisty/`).

Wymagany jest internet: Tailwind (CDN 3.4.17 z wtyczką forms, `colors.page = #f4f7f9`), biblioteka Supabase (CDN, wersja przypięta) oraz `kamilowebski.github.io/hub/apps.js`.

## Jak działają zdjęcia

- Pliki leżą w buckecie `checklisty-zdjecia` w folderze `<user_id>/`, a w bazie zapisane są tylko ścieżki. Bucket jest prywatny, aplikacja pobiera linki podpisywane ważne godzinę.
- Wykonanie dostaje kopię kroków wraz ze ścieżkami zdjęć wzorcowych. Zdjęcie wzorcowe usunięte z procedury zostaje w Storage, dopóki korzysta z niego jakieś wykonanie.
- Zdjęcia wysłane podczas edycji procedury, której nie zapiszesz, są usuwane po zamknięciu okna.
- Usunięcie wykonania kasuje także jego własne zdjęcia.

## Wspólny wygląd (Rejestr, Todo, Diary i nowe strony)

- tylko jasny motyw, tło `bg-page` (`#f4f7f9`), jeden akcent `blue-600`
- kontener `max-w-7xl mx-auto px-4 py-8 space-y-6`, nagłówek z tytułem po lewej i akcjami po prawej
- te same przyciski: główny (Dodaj, Zapisz), drugorzędny (Wyloguj, Anuluj), niebezpieczny (Usuń), ikony jako inline SVG
- logowanie jako karta `max-w-md` na stronie, okna `max-w-[560px]`, potwierdzenie `max-w-[400px]`
- przycisk huba (kwadraciki) w prawym górnym rogu, ładowany z `hub/apps.js` do `<div id="hub-apps">`

## Uwagi

- Bezpieczeństwo opiera się na RLS w Supabase i politykach Storage. Klucz „publishable" w kodzie jest bezpieczny tylko przy włączonym RLS.
- Limit pliku (5 MB) ustawia bucket. Przy zdjęciach zmniejszanych do 1600 px zwykle zostaje to z dużym zapasem.
