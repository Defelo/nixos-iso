{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
  };
  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};
  in {
    packages.${system}.default = self.nixosConfigurations.iso.config.system.build.isoImage;
    nixosConfigurations.iso = nixpkgs.lib.nixosSystem {
      inherit system pkgs;
      modules = [
        (nixpkgs + /nixos/modules/installer/cd-dvd/installation-cd-minimal.nix)
        (nixpkgs + /nixos/modules/installer/cd-dvd/channel.nix)
        {
          time.timeZone = "Europe/Berlin";

          i18n.defaultLocale = "en_US.UTF-8";
          console.keyMap = "de";

          programs.zsh.enable = true;
          users.defaultUserShell = pkgs.zsh;

          environment.variables = {
            EDITOR = "nvim";
            VISUAL = "nvim";
          };

          environment.pathsToLink = ["/share/zsh"];

          services.getty.autologinUser = pkgs.lib.mkForce "root";

          nix = {
            nixPath = ["nixpkgs=${nixpkgs}"];
            settings = {
              experimental-features = ["nix-command" "flakes" "repl-flake"];
            };
            registry = {
              nixpkgs = {
                from = {
                  id = "nixpkgs";
                  type = "indirect";
                };
                exact = true;
                flake = nixpkgs;
              };
            };
          };

          environment.systemPackages = with pkgs; [
            git
            gnupg
            neovim
            wget
            curl
            htop
            file
            jq
            yq
            wirelesstools
            iw
            duf
            ncdu
            neofetch
            speedtest-cli
            zip
            unp
            pwgen
            dig
            xxd
            ripgrep
            sd
            age
            sops
            renameutils
            nvd
            nix-tree
          ];
        }
      ];
    };
  };
}
