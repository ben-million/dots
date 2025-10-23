{
  description = "Emacs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs { inherit system; };

      emacs = pkgs.emacs.pkgs.withPackages (
        epkgs: with epkgs; [
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
        ]
      );
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
