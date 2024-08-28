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
    packages = forAllSystems (system: let
      pkgs = import nixpkgs { inherit system; };
    in {
      default = self.packages.${system}.envrund;
      envrund = pkgs.stdenv.mkDerivation {
        name = "envrund";
        pname = "envrund";
        src = ./.;

        nativeBuildInputs = with pkgs; [ coreutils ];

        installPhase = ''
          mkdir -p $out/bin
          install -t $out/bin -m 755 envrund envrun 
        '';
      };
    });
  };
}
