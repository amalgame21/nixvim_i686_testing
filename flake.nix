{
  description = "A very basic flake";

  inputs = {
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "i686-linux";
      };
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    i686-linux = {
      url = "path:./i686-linux.nix";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      nixvim,
      ...
    }:
    let
      config = {
        colorschemes.gruvbox.enable = true;
      };

      systems = [
        "i686-linux"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;

    in
    {
      packages = forAllSystems (
        system:
        let
          nixpkgs-patched = (import nixpkgs { inherit system; }).applyPatches {
            name = "disabledTestPaths";
            src = nixpkgs;
            patches = [ ./disabledTestPaths.patch ];
          };

          pkgs = import nixpkgs-patched { inherit system; };

          nixvim' = nixvim.legacyPackages.${system};
          nvim = nixvim'.makeNixvimWithModule {
            inherit pkgs;
            module = config;
          };
        in
        {
          inherit nvim;
          default = nvim;
          pr = pkgs.python313Packages.pytest-regressions;
        }
      );
    };
}
