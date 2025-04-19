{
  lib,
  fetchzip,
  stdenv,
  libgcc,
  libX11,
  gtk3-x11,
  libunwind,
  libglibutil,
  autoPatchelfHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "coolterm";
  version = "2.3.0";

  src =
    let
      urlVersion = builtins.replaceStrings [ "." ] [ "" ] finalAttrs.version;
    in
    fetchzip {
      url = "https://freeware.the-meiers.org/previous/CoolTermLinux64Bit${urlVersion}.zip";
      hash = "sha256-6r4AHJZa0LPpqokcsE+034yosyMW+6qJvLHd9R04GGg=";
    };

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    libgcc
    libX11 
    gtk3-x11  
    libunwind
    libglibutil
  ];

  installPhase = ''
    mkdir -p $out
    cp -r * $out/
  '';

  meta = with lib; {
    description = "CoolTerm";
    homepage = "https://freeware.the-meiers.org/";
    meta.license = lib.licenses.unfree;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
  };
})
