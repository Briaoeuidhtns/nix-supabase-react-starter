{
  description = "TanStack Start and Supabase development shell";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      forEachSystem = nixpkgs.lib.genAttrs systems;
    in
    {
      devShells = forEachSystem (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
          syncSupabaseEnv = pkgs.writeShellApplication {
            name = "sync-supabase-env";
            runtimeInputs = [
              pkgs.coreutils
              pkgs.gnused
              pkgs.supabase-cli
            ];
            text = ''
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
          };
        in
        {
          default = pkgs.mkShell {
            packages = [
              pkgs.biome
              pkgs.docker-client
              pkgs.git
              pkgs.nodejs_22
              pkgs.pnpm
              pkgs.postgresql_17
              pkgs.supabase-cli
              pkgs.typescript-language-server
              syncSupabaseEnv
            ]
            ++ pkgs.lib.optional (system == "x86_64-linux") pkgs.opencode-desktop;

            DO_NOT_TRACK = "1";
            SUPABASE_TELEMETRY_DISABLED = "1";
            SUPABASE_URL = "http://127.0.0.1:55321";
            SUPABASE_DB_URL = "postgresql://postgres:postgres@127.0.0.1:55322/postgres";
            VITE_SUPABASE_URL = "http://127.0.0.1:55321";
          };
        }
      );
    };
}
