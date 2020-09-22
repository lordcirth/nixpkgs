{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.xboxdrv;
in {
  options = {
    services.xboxdrv = {
      enable = mkEnableOption "Xbox/Xbox360 gamepad driver for Linux that works in userspace";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.xboxdrv = {
      description = "Xbox/Xbox360 gamepad driver"
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig.ExecStart = "${xboxdrv} --daemon --silent"
    };
  };
};
