{
    description = "A Nix flake packaging Cookery";

    inputs = {
        nixpkgs.url     = "github:nixos/nixpkgs/nixos-23.11";
        flake-utils.url = "github:numtide/flake-utils";
    };

    outputs = { self, nixpkgs, flake-utils } :
    flake-utils.lib.eachDefaultSystem (system:
        let
            pkgs = import nixpkgs { inherit system; };
            # Build Cookery as a Nix package
            cookery = pkgs.stdenv.mkDerivation {
                pname   = "cookery";
                version = "1.0.0";
                src     = ./.;

                # Dependancies needed for building
                nativeBuildInputs = [ pkgs.makeWrapper ];

                # Dependancies needed at runtime
                buildInputs = with pkgs; [
                    ffmpeg
                    coreutils
                    imagemagick
                ];

                installPhase = ''
                    # 1. Create the destination directory
                    mkdir -p $out/bin
                    cp cook $out/bin/cookery

                    # 2. Make it executable
                    chmod +x $out/bin/cookery
                '';

                # Make Dependancies avaible at runtime
                postFixup = ''
                    wrapProgram $out/bin/cookery \
                    --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.ffmpeg pkgs.imagemagick pkgs.coreutils ]}
                '';
            };

        in {
            packages.default = cookery;
            apps.default = {
                type    = "app";
                program = "${cookery}/bin/cookery";
            };
        }
    );
}
