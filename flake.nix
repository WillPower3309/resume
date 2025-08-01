{
  description = "LaTeX Resume";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixpkgs-unstable;
    flake-utils.url = github:numtide/flake-utils;
  };

  outputs = { self, nixpkgs, flake-utils }:
    with flake-utils.lib; eachSystem allSystems (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      tex = pkgs.texliveBasic.withPackages(ps: with ps; [
        latexmk
        extsizes
        fontawesome
        fontspec
        xcolor
        pgf # contains tikz
        tcolorbox
        tikzfill
        enumitem
        dashrule
        ifmtarg
        multirow
        changepage
        lato
        fontaxes
        xkeyval
      ]);
    in rec {
      packages = {
        resume-pdf = pkgs.stdenvNoCC.mkDerivation rec {
          name = "latex-resume";
          src = self;
          buildInputs = [ pkgs.coreutils tex ];
          phases = [ "unpackPhase" "buildPhase" ];
          buildPhase = ''
              env HOME=$(mktemp -d) \
              latexmk -interaction=nonstopmode -pdf -lualatex -cd \
              -output-directory=$out -jobname=resume src/main.tex
          '';
        };

        default = packages.resume-pdf;
      };

      devShells.default = pkgs.mkShell {
        name = "resume-shell";
        inputsFrom = [ packages.resume-pdf ];
      };
    });
}

