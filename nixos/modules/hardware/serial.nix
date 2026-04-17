{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.hardware.serial;
in
{
  options.hardware.serial = {
    enable = lib.mkEnableOption ''
      access to USB-attached serial devices (`/dev/ttyUSB*`, `/dev/ttyACM*`)
      for users on the active local seat, via the systemd-logind `uaccess`
      mechanism.

      When enabled, the user currently logged in on the physical console
      automatically receives read/write access via POSIX ACLs, without
      needing `dialout` group membership. Access is revoked on logout or
      device removal, and SSH sessions (which have no seat) are not granted
      access.

      Platform UARTs (`ttyS*`, `ttyAMA*`, `ttymxc*`, ...) are intentionally
      not tagged, as they commonly serve as serial consoles on servers and
      embedded systems where this behavior would be wrong
    '';
  };

  config = lib.mkIf cfg.enable {
    services.udev.packages = lib.singleton (
      pkgs.writeTextFile {
        name = "serial-uaccess-udev-rules";
        destination = "/etc/udev/rules.d/73-seat-serial.rules";
        text = ''
          # Platform UARTs (ttyS*, ttyAMA*, ...) are intentionally excluded;
          # they're often the serial console on servers and embedded boards.
          SUBSYSTEM=="tty", KERNEL=="ttyUSB[0-9]*", TAG+="uaccess"
          SUBSYSTEM=="tty", KERNEL=="ttyACM[0-9]*", TAG+="uaccess"
        '';
      }
    );
  };

  meta.maintainers = [ ];
}
