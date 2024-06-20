{
    outputs = { self, nixpkgs }: let
        overlays = [
            (final: prev: rec {
                gcc = prev.gcc14;
            })
        ];
        supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
        forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
            pkgs = import nixpkgs { inherit overlays system; };
        });
    in {
        devShells = forEachSupportedSystem ({ pkgs }: {
            default = pkgs.mkShell.override {
                stdenv = pkgs.llvmPackages_18.stdenv;
            }
            {
                packages = with pkgs; [
                    autoconf
                    automake
                    clang_18
                    cmake
                    conan
                    docker
                    docker-compose
                    doxygen
                    gcc
                    libtool
                    pkg-config
                    pre-commit
                ] ++ (if system == "x86_64-linux" then [ lsb-release ] else []);
                shellHook = ''
                    pre-commit install -f --hook-type pre-commit
                '';
            };
        });
    };
}
