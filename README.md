# append.io

All-in-one dashboard for your brokerage and retirement accounts. Link
Fidelity, Vanguard, Schwab, Robinhood, 401(k)s, IRAs, HSAs and more through
Plaid, and see your combined net worth, allocation, and holdings in one app.

## Architecture

```
Flutter app (my_dashboard/)
   │  opens Plaid Link, reads accounts/holdings
   ▼
Supabase (supabase/)
   ├─ Postgres + RLS  ── accounts, holdings, plaid_items (tokens locked down)
   └─ Edge functions ── create-link-token / exchange-public-token / sync-investments
        │  Plaid client_id + secret live ONLY here
        ▼
      Plaid Investments API
```

The Plaid **secret never ships in the app**. The Flutter client only ever
sees a short-lived `link_token` and its own rows in Postgres.

## Run it right now (demo mode)

No keys needed — the app falls back to realistic mock data:

```sh
cd my_dashboard
flutter run    # pick Chrome, Windows, or an Android emulator
```

## Going live

### 1. Supabase

1. Create a project at [supabase.com](https://supabase.com).
2. Run the schema: paste `supabase/migrations/0001_init.sql` into the SQL
   editor (or `supabase db push` with the CLI).
3. Enable **Anonymous sign-ins** (Authentication → Providers) — the app
   currently uses an anonymous session; swap in real auth before launch.

### 2. Plaid

1. Create a free account at [dashboard.plaid.com](https://dashboard.plaid.com)
   — Sandbox is free and works with fake credentials (`user_good` / `pass_good`).
2. Grab your `client_id` and sandbox `secret`.

### 3. Deploy the edge functions

```sh
supabase login
supabase link --project-ref <your-project-ref>
supabase secrets set PLAID_CLIENT_ID=... PLAID_SECRET=... PLAID_ENV=sandbox
supabase functions deploy create-link-token exchange-public-token sync-investments
```

### 4. Run the app with your keys

Copy `my_dashboard/env.example.json` to `env.json` (git-ignored) and fill in
your Supabase URL and publishable key, then:

```sh
cd my_dashboard
flutter run --dart-define-from-file=env.json
```


Tap **Connect** on the Accounts tab → Plaid Link opens → choose any
institution (sandbox: `user_good` / `pass_good`) → holdings sync and the
dashboard updates.

## iOS notes

- iOS builds require macOS/Xcode. Day-to-day development works fine on
  Windows against Chrome/Android; build the iOS app on a Mac or a CI
  service (Codemagic, GitHub Actions macOS runners).
- Before shipping iOS: set a unique bundle identifier, and configure an
  OAuth redirect URI in the Plaid dashboard for institutions that use
  OAuth (Schwab, Chase, etc.).

## Roadmap ideas

- Real authentication (email magic link or Sign in with Apple)
- Historical net-worth chart (snapshot table + scheduled sync via pg_cron)
- Asset-class allocation (stocks/bonds/cash) from Plaid security types
- Account unlinking + Plaid update mode for expired credentials
- Push notification on large daily moves
