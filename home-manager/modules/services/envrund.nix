{
  self,
  ...
}:
{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.envrund;
  description = "Daemon for running programs with this user's environment";
in {
  options.services.envrund = {
    enable = mkEnableOption "Enable `envrund` - ${description}"; 
  };
  config = mkIf cfg.enable {
    systemd.user.services.envrund = {
      Unit.Description = description;

      Install.WantedBy = [ "default.target" ];

      Service.Type = "exec";
      Service.MemorySwapMax = 0;
      Service.ExecStart = ''
        "${self.packages.${pkgs.system}.envrund}/bin/envrund"
      '';
    };
    systemd.user.services.graphical-session-restart-envrund = {
      Unit = {
        Description = "Restart `envrund` service when graphical session starts";
        After = "graphical-session.target";
        Requisite = "graphical-session.target";
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };

      Service = {
        Type = "exec";
        ExecStart = "systemctl --user restart envrund.service";

        # Sandboxing
        NoNewPrivileges = "yes";
        ProtectKernelTunables = "yes";
        ProtectControlGroups = "yes";
        LockPersonality = "true";
        MemoryDenyWriteExecute = "true";
        PrivateUsers = "true";
        RestrictNamespaces = "true";
        SystemCallArchitectures = "native";
        SystemCallFilter = "@system-service";
      };
    };
  };
}
