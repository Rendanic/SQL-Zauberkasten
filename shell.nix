{ pkgs ? import <nixpkgs> {} }:

let
  # Version is updated by Renovate (see renovate.json).
  # No hash on purpose: fetchTarball is not pinned and changes with every release.
  sqlclVersion = "26.3.1.301.1413";
  myZip = builtins.fetchTarball {
    url = "https://download.oracle.com/otn_software/java/sqldeveloper/sqlcl-${sqlclVersion}.zip";
  };
in
pkgs.mkShell {
  buildInputs = [
    pkgs.pre-commit
    pkgs.tig
    pkgs.shellcheck
    pkgs.shfmt
    pkgs.jdk21
    pkgs.go-task
    pkgs.renovate
    pkgs.jq
  ];

  shellHook = ''
    export EDITOR=vi
    export PATH="${myZip}/bin:$PATH"

    # SQLCL_BIN is needed by task in tools
    export SQLCL_BIN=$(which sql)
  '';
}
