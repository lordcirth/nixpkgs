{ config, lib, pkgs, ... }:
with lib;
let
  inherit (pkgs) ipfs ipfs-cluster runCommand makeWrapper;

  cfg = config.services.ipfs-cluster;

  ipfsClusterFlags = toString ([]);

  defaultDataDir = "/var/lib/ipfs-cluster";

  # Wrapping the ipfs-cluster-service binary with the environment variable IPFS_CLUSTER_PATH set to dataDir because we can't set it in the user environment
  wrapped = runCommand "ipfs-cluster-service" { buildInputs = [ makeWrapper ]; preferLocalBuild = true; } ''
    mkdir -p "$out/bin"
    makeWrapper "${ipfs-cluster}/bin/ipfs-cluster-service" "$out/bin/ipfs-cluster-service" \
      --set IPFS_CLUSTER_PATH ${cfg.dataDir} \
      --prefix PATH : /run/wrappers/bin
  '';

  commonEnv = {
    environment.IPFS_CLUSTER_PATH = cfg.dataDir;
    path = [ wrapped ];
    serviceConfig.User = cfg.user;
    serviceConfig.Group = cfg.group;
  };

  baseService = recursiveUpdate commonEnv {
    serviceConfig = {
      ExecStart = "${wrapped}/bin/ipfs-cluster-service daemon ${ipfsClusterFlags}";
      Restart = "on-failure";
      RestartSec = 1;
    };
  };

in {

  ###### interface

  options = {

    services.ipfs-cluster = {

      enable = mkEnableOption "IPFS pinset orchestrator (Requires an ipfs daemon to function)";

      dataDir = mkOption {
        type = types.str;
        default = defaultDataDir;
        description = "The data dir for IPFS Cluster";
      };

      user = mkOption {
        type = types.str;
        default = "ipfs-cluster";
        description = "User under which the IPFS daemon runs";
      };

      group = mkOption {
        type = types.str;
        default = "ipfs-cluster";
        description = "Group under which the IPFS Cluster daemon runs";
      };
    };
  };

  ###### implementation
  config = mkIf cfg.enable {
    environment.systemPackages = [ wrapped ];

    users.users = mkIf (cfg.user == "ipfs-cluster") {
      ipfs-cluster = {
        group = cfg.group;
        home = cfg.dataDir;
        createHome = false;
        uid = config.ids.uids.ipfs-cluster;
        description = "IPFS daemon user";
      };
    };

    users.groups = mkIf (cfg.group == "ipfs-cluster") {
      ipfs-cluster.gid = config.ids.gids.ipfs-cluster;
    };

    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}' - ${cfg.user} ${cfg.group} - -"
    ];

    systemd.services.ipfs-cluster-init = recursiveUpdate commonEnv {
      description = "IPFS Cluster Initializer";
      before = [ "ipfs-cluster.service" ];

      script = ''
        if [[ ! -f ${cfg.dataDir}/config ]]; then
          ipfs-cluster-service init
        fi
      '';

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
    };

    systemd.services.ipfs-cluster = recursiveUpdate baseService {
      description = "IPFS Cluster Daemon";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" "ipfs-cluster-init.service" ];
      # conflicts = [ "ipfs-offline.service" "ipfs-norouting.service"];
    };
  };
}
