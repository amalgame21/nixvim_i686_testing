{
  description = "A very basic flake";

  inputs = {
    nixpkgs.follows = "nixvim/nixpkgs";
    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.systems.follows = "i686-linux";
    i686-linux = {
      url = "path:./i686-linux.nix";
      flake = false;
    };
  };

  outputs =
    { nixpkgs, nixvim, ... }:
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
          nixvim' = nixvim.legacyPackages.${system};
          nvim = nixvim'.makeNixvim config;
        in
        {
          inherit nvim;
          default = nvim;
        }
      );
    };
}
