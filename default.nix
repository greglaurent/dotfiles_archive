{ config, inputs, lib, pkgs, ... }: 
let 
  inherit (lib) _;
in { 
  imports = [ inputs.home-manager.nixosModules.home-manager ]
    ++ (mapModulesRec' (toString ./modules import);
}
