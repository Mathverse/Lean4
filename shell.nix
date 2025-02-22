let
  flake = (import ./default.nix);
  flakePkgs = flake.packages.${builtins.currentSystem};
in { pkgs ? flakePkgs.nixpkgs, pkgsDist ? pkgs, llvmPackages ? null }:
# use `shell` as default
(attribs: attribs.shell // attribs) rec {
  shell = pkgs.mkShell.override {
    stdenv = pkgs.overrideCC pkgs.stdenv (if llvmPackages == null
                                          then flakePkgs.llvmPackages
                                          else pkgs.${"llvmPackages_${llvmPackages}"}).clang;
  } (rec {
    buildInputs = with pkgs; [ cmake gmp ccache ];
    # https://github.com/NixOS/nixpkgs/issues/60919
    hardeningDisable = [ "all" ];
    # more convenient `ctest` output
    CTEST_OUTPUT_ON_FAILURE = 1;
  } // pkgs.lib.optionalAttrs pkgs.stdenv.isLinux {
    GMP = pkgsDist.gmp.override { withStatic = true; };
    GLIBC = pkgsDist.glibc;
    ZLIB = pkgsDist.zlib;
  });
  with-temci = shell.overrideAttrs (old: {
    buildInputs = old.buildInputs ++ [ flakePkgs.temci ];
  });
  nix = flake.devShell.${builtins.currentSystem};
}
