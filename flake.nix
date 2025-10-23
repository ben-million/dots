{
  description = "My Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    emacs.url = "path:./emacs";
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = builtins.currentSystem or "aarch64-darwin";
      pkgs = import nixpkgs { inherit system; };
    in {
      homeConfigurations."benmaclaurin" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          {
            home.username = "benmaclaurin";
            home.homeDirectory = "/Users/benmaclaurin";

            programs.home-manager.enable = true;

            # Example configuration:
            programs.zsh.enable = true;
            programs.git = {
              enable = true;
              userName = "Ben";
              userEmail = "ben@million.dev";
            };

            home.packages = with pkgs; [
              emacs
            ];

            home.stateVersion = "24.05";
          }
        ];
      };
    };
}
