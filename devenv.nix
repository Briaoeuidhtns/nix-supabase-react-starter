{ pkgs, lib, ... }:

let
  syncSupabaseEnv = pkgs.writeShellScriptBin "sync-supabase-env" ''
    set -euo pipefail

    status="$(supabase status -o env)"

    get_var() {
      printf '%s\n' "$status" | sed -n "s/^$1=//p" | tail -n 1
    }

    supabase_url="$(get_var API_URL)"
    if [ -z "$supabase_url" ]; then
      supabase_url="$(get_var SUPABASE_URL)"
    fi

    publishable_key="$(get_var PUBLISHABLE_KEY)"
    if [ -z "$publishable_key" ]; then
      publishable_key="$(get_var ANON_KEY)"
    fi

    if [ -z "$supabase_url" ] || [ -z "$publishable_key" ]; then
      echo "Could not read Supabase URL/key from 'supabase status -o env'." >&2
      exit 1
    fi

    cat > .env.local <<EOF
VITE_SUPABASE_URL=$supabase_url
VITE_SUPABASE_PUBLISHABLE_KEY=$publishable_key
EOF

    echo "Wrote .env.local for Vite."
  '';

  supabaseDev = pkgs.writeShellScriptBin "supabase-dev" ''
    set -euo pipefail

    if ! docker info >/dev/null 2>&1; then
      echo "A Docker-compatible runtime is required for local Supabase." >&2
      echo "Start Docker, Podman, Rancher Desktop, OrbStack, or Colima, then run devenv up again." >&2
      exit 1
    fi

    supabase start
    supabase migration up --local
    sync-supabase-env

    cleanup() {
      supabase stop || true
    }
    trap cleanup EXIT INT TERM

    while true; do
      sleep 86400 &
      wait $!
    done
  '';

  viteDev = pkgs.writeShellScriptBin "vite-dev" ''
    set -euo pipefail

    for _ in $(seq 1 60); do
      if [ -s .env.local ] && grep -q '^VITE_SUPABASE_PUBLISHABLE_KEY=' .env.local; then
        break
      fi
      sleep 1
    done

    pnpm dev
  '';
in
{
  packages = with pkgs; [
    biome
    docker-client
    git
    postgresql_17
    supabase-cli
    typescript-language-server
    syncSupabaseEnv
    supabaseDev
    viteDev
  ] ++ lib.optional (stdenv.isLinux && stdenv.hostPlatform.isx86_64) opencode-desktop;

  languages.javascript = {
    enable = true;
    pnpm = {
      enable = true;
      install.enable = true;
    };
  };

  env = {
    DO_NOT_TRACK = "1";
    SUPABASE_TELEMETRY_DISABLED = "1";
    SUPABASE_URL = "http://127.0.0.1:55321";
    SUPABASE_DB_URL = "postgresql://postgres:postgres@127.0.0.1:55322/postgres";
    VITE_SUPABASE_URL = "http://127.0.0.1:55321";
  };

  processes.supabase.exec = "supabase-dev";
  processes.web.exec = "vite-dev";

  enterShell = ''
    echo "TanStack Start + Supabase dev shell"
    echo "Run: devenv up"
    echo "Supabase Studio: http://127.0.0.1:55323"
    echo "TanStack app:    http://127.0.0.1:3000"
  '';
}
