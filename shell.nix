{ pkgs ? import <nixpkgs> {} }:

let
  myZip = pkgs.fetchzip {
    # Use `nix-prefetch-url --unpack <url>` to get this
    url = "https://download.oracle.com/otn_software/java/sqldeveloper/sqlcl-26.1.0.086.1709.zip";
    sha256 = "04l5bdbaga8f7cmfgk6i980klqi70h96yvzfa52nd6pphfskvqkz";
  };
in
pkgs.mkShell {
  buildInputs = [
    pkgs.pre-commit
    pkgs.tig
    pkgs.jdk21
    pkgs.go-task
  ];

  shellHook = ''
    export EDITOR=vi
    export PATH="${myZip}/bin:$PATH"

    # SQLCL_BIN is needed by task in tools
    export SQLCL_BIN=$(which sql)
  '';
}
