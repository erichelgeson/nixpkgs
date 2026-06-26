{
  lib,
  stdenv,
  fetchFromGitHub,
  kernel,
  kernelModuleMakeFlags,
}:

stdenv.mkDerivation {
  pname = "appletalk";
  version = "0-unstable-2026-06-16-${kernel.version}";

  src = fetchFromGitHub {
    owner = "linux-netdev";
    repo = "mod-orphan";
    rev = "43fe23aae3e97f961841a6d64596985ee9f3e631";
    hash = "sha256-CEJ4xpe3Tla/v+ULEQe+drfcNbmKbW1c61dRrURDqAk=";
  };

  hardeningDisable = [ "pic" ];

  nativeBuildInputs = kernel.moduleBuildDependencies;

  # mod-orphan collects every networking subsystem that has been orphaned out
  # of the mainline kernel (AX.25, NET/ROM, ROSE, ATM, ISDN, Bluetooth CMTP,
  # AppleTalk, ...). We only want AppleTalk, so drop the other obj-m entries
  # while keeping the LINUXINCLUDE/compat-header setup the build relies on:
  # the AppleTalk sources include <linux/atalk.h>, which only resolves to the
  # in-repo copy through the top-level Kbuild's LINUXINCLUDE.
  postPatch = ''
    sed -i '/^obj-m/d' Kbuild
    echo 'obj-m += net/appletalk/' >> Kbuild
  '';

  makeFlags = kernelModuleMakeFlags ++ [
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "INSTALL_MOD_PATH=${placeholder "out"}"
  ];

  installTargets = [ "install" ];

  meta = {
    description = "Out-of-tree AppleTalk (DDP/AARP) protocol kernel module, removed from mainline in Linux 7.1";
    longDescription = ''
      The AppleTalk (DDP/AARP) protocol was removed from the mainline Linux
      kernel in 7.1 and is now maintained out of tree alongside the other
      orphaned networking modules (AX.25, hamradio, ...) at
      github.com/linux-netdev/mod-orphan. This package builds just the
      `appletalk` module against the running kernel.

      EtherTalk runs over 802.2 SNAP, so the host kernel must provide
      `register_snap_client()` (CONFIG_LLC). Enable CONFIG_LLC2 (or another LLC
      user) in the kernel if you need EtherTalk; in-tree this used to be pulled
      in automatically by `config ATALK select LLC`.
    '';
    homepage = "https://github.com/linux-netdev/mod-orphan";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ nulleric ];
    # AppleTalk was still in-tree before 7.1; out-of-tree builds target the
    # kernels that no longer ship it.
    broken = kernel.kernelOlder "7.1";
  };
}
