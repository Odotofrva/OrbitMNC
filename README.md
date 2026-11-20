# MENOCLONE ORBIT — MENOCLONE LABS

Mobile-first team calendar and task manager for GitHub Pages + Supabase. Dark glass interface, alien crew avatars, email/password auth, task assignment, completion, calendar, and installable PWA shell.

## Deploy
1. Create a Supabase project. Open SQL Editor and run `schema.sql`.
2. In Authentication → Providers, enable Email; enable email confirmation. For a private team, disable public signups after creating or inviting your team accounts.
3. In `config.js`, paste your project URL and **public anon/publishable key**. NEVER paste a service role/secret key.
4. In Supabase Authentication → URL Configuration, set your GitHub Pages URL as Site URL and an allowed redirect URL.
5. After a user signs up, approve them in SQL Editor: `insert into public.team_members(user_id) values ('USER_UUID_FROM_AUTH_USERS');` Repeat for each teammate. Unapproved users cannot read or modify team data.
6. Upload this folder's files to a GitHub repository. In Settings → Pages choose Deploy from branch, main, root. Open the published URL via HTTPS.
7. For profile edits or more advanced role management, add an admin-only settings screen in a future version.

## Security
All task/profile access is guarded by Supabase row-level security (RLS), not just the UI. Membership approvals are database-admin only. Every approved team member can currently read, update, and delete every task; adjust policies if granular permissions are needed. Sign-in and sign-up are handled by Supabase Auth. Public preview data is local in-memory only; it is not shared or persisted.

## Notes
`app.js` loads supabase-js via jsDelivr; initial use requires an internet connection. The PWA caches only same-origin shell assets, not private team data. The UI takes inspiration from contemporary mobile glass and tactile interactions, without claiming to reproduce proprietary iPhone features. The MENOCLONE top wordmark is typography; replace it with your official logo asset when available.
