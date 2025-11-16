{ pkgs ? import <nixpkgs> {
  config.allowUnfree = true;
} }:

let
  myZip = pkgs.fetchzip {
    # Use `nix-prefetch-url --unpack <url>` to get this
    url = "https://download.oracle.com/otn_software/java/sqldeveloper/sqlcl-24.4.4.086.1931.zip";
    sha256 = "0svgwciz9b8ka0wf7k833zj0x8d7scbmpwsb7gkqn5xim2mxa5bc";
  };
in
pkgs.mkShell {
  buildInputs = [
    pkgs.pre-commit
    pkgs.ncdu
    pkgs.tig
    pkgs.tree
    pkgs.jdk21
    pkgs.go-task
    pkgs.rlwrap
    pkgs.oracle-instantclient
  ];

  shellHook = ''
    export EDITOR=vi
    export PATH="${myZip}/bin:$PATH"

    # SQLCL_BIN is needed by task in tools
    export SQLCL_BIN=$(which sql)

    if [ -z "$ORACLE_HOME" ]; then
      export ORACLE_HOME="${pkgs.oracle-instantclient}/lib"
      export PATH="${pkgs.oracle-instantclient}/bin:$PATH"
    fi

    if [ -z "$LD_LIBRARY_PATH" ]; then
      export LD_LIBRARY_PATH="${pkgs.oracle-instantclient}/lib:$LD_LIBRARY_PATH"
    fi

  '';
}
