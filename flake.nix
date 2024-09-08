{
  description = "Little daemon that runs piped commands";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: let
    forAllSystems = nixpkgs.lib.genAttrs systems;
    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  in {
    homeManagerModules = {
      default = self.homeManagerModules.envrund;
      envrund = import ./home-manager/modules/services/envrund.nix { inherit self; };
    };
    packages = forAllSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      inherit (pkgs) lib;
    in {
      default = self.packages.${system}.envrund;
      envrund = pkgs.stdenv.mkDerivation {
        name = "envrund";
        pname = "envrund";
        src = ./.;

        nativeBuildInputs = with pkgs; [ makeWrapper ];

        installPhase = ''
          mkdir -p $out/bin
          install -t $out/bin -m 755 envrund envrun 
        '';

        postFixup = with pkgs; ''
          for bin in $out/bin/*; do
            wrapProgram $bin \
              --suffix PATH ${lib.makeBinPath [
                coreutils
                gnugrep
                bash
                procps
              ]}
          done
        '';
      };
    });
  };
}
