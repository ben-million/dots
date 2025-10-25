{
  description = "Emacs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs { inherit system; };

      emacs = pkgs.emacs.pkgs.withPackages (epkgs: with epkgs; [
        use-package
        magit
        spacious-padding
        vertico
        marginalia
        orderless
        corfu
        dired-subtree
        trashed
        treesit-auto
        web-mode
        eglot
        exec-path-from-shell
        consult
        fontaine
        vterm
        ultra-scroll
        
        (epkgs.trivialBuild {
          pname = "time-zones";
          version = "2025-01-01";
          src = pkgs.fetchFromGitHub {
            owner = "xenodium";
            repo = "time-zones";
            rev = "328c97fa53e07179d69f0333bfc54d4def75b1c1";
            sha256 = "sha256-zolNEgR7iuXt4ZU1vcZHb1dXZ6H+ZcxWHTh97KsIq4A=";
          };
        })

        (epkgs.trivialBuild {
          pname = "doric-themes";
          version = "2025-01-01";
          src = pkgs.fetchFromGitHub {
            owner = "protesilaos";
            repo = "doric-themes";
            rev = "fccfa980635d5df00bc1be29908b9bcbbe3aa9f5";
            sha256 = "sha256-zolNEgR7iuXt4ZU1vcZHb1dXZ6H+ZcxWHTh97KsIq4A=";
          };
        })
      ]);
    in
    {
      packages.${system}.default = emacs;

      apps.${system}.default = {
        type = "app";
        program = "${pkgs.writeShellScriptBin "run-emacs" ''
          exec ${emacs}/bin/emacs \
            --no-init-file \
            --no-site-file \
            --load ${./init.el} \
            "$@"
        ''}/bin/run-emacs";
      };
    };
}
