# Nix Supabase Starter

TanStack Start development environment with TanStack Query, Table, Form, Router, Tailwind CSS, Biome, Nix, devenv, pnpm, local Supabase, and `opencode-desktop`.

## Requirements

- Nix
- devenv CLI 2.1 or newer (`nix profile install nixpkgs#devenv`)
- A running Docker-compatible runtime for Supabase containers

## Start

```sh
devenv shell
# Inside the devenv shell:
devenv up
```

`devenv up` starts the local Supabase stack, applies pending migrations, writes `.env.local` for Vite, and runs the TanStack Start dev server.

To activate the environment automatically, install direnv with its shell hook and run `direnv allow`. The checked-in `.envrc` uses the devenv CLI directly; it does not evaluate a flake.

## URLs

- TanStack app: http://127.0.0.1:3000
- Supabase Studio: http://127.0.0.1:55323
- Supabase API: http://127.0.0.1:55321
- Postgres: `postgresql://postgres:postgres@127.0.0.1:55322/postgres`

## Commands

- `devenv shell`: enter the development environment
- `devenv update`: update the pinned inputs in `devenv.lock`
- `pnpm dev`: run TanStack Start with Vite
- `pnpm build`: build the production server and client bundles
- `pnpm test`: run the Vitest suite
- `pnpm check`: check source files with the Nix-provided Biome binary
- `pnpm lint`: lint source files with Biome
- `pnpm format --write`: format source files with Biome
- `pnpm supabase:status`: show local Supabase status
- `pnpm supabase:env`: refresh `.env.local` from the running local stack
- `supabase migration up --local`: apply pending local migrations
- `supabase stop`: stop the local Supabase stack
- `opencode-desktop`: launch OpenCode Desktop from the dev shell on x86_64 Linux

Biome comes from nixpkgs at the version expected by `biome.json`; the npm native binary is intentionally not installed.

## OpenCode

This repo includes project-local OpenCode config in `.opencode/opencode.json`.

- MCP server: `supabase-local` at `http://127.0.0.1:55321/mcp`
- Skills: official Supabase Agent Skills from `https://supabase.com/.well-known/agent-skills/`

Start Supabase with `devenv up` before using the Supabase MCP tools. Restart OpenCode after changing files under `.opencode/`.
