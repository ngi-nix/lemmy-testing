{
  description = "Nix flake for testing Lemmy";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      systemConfig = {
        services.lemmy = {
          enable = true;
          ui.port = 1234;
          jwtSecretPath = pkgs.writeTextFile {
            name = "lemmy-secret";
            text = "very-secret-password123";
          };
          settings = {
            hostname = "localhost";
            port = 8536;
            database.createLocally = true;
          };
        };
      };
    in
    {
      checks.${system}.lemmy = pkgs.nixosTest {
        name = "lemmy";

        nodes.machine = systemConfig;

        testScript = ''
          # Wait for backend service to start
          machine.wait_for_unit("lemmy.service")
          machine.wait_for_open_port(${toString systemConfig.services.lemmy.settings.port})

          # Wait for webui services to start
          machine.wait_for_unit("lemmy-ui.service")
          machine.wait_for_open_port(${toString systemConfig.services.lemmy.ui.port})

          # curl the backend's API and the webui
          machine.succeed("curl --fail localhost:${toString systemConfig.services.lemmy.settings.port}/api/v3/site")
          machine.succeed("curl --fail localhost:${toString systemConfig.services.lemmy.ui.port}")
        '';
      };

      nixosConfigurations.container = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          systemConfig
          {
            boot.isContainer = true;
            networking.firewall.allowedTCPPorts = with systemConfig.services.lemmy; [ settings.port ui.port ];
          }
        ];
      };
    };
}
