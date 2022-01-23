{ stdenv
, lib
, mkWindowsApp
, wine
, fetchurl
, makeDesktopItem
, makeDesktopIcon
, copyDesktopItems
, copyDesktopIcons
, unzip
, imagemagick }:
mkWindowsApp rec {
  inherit wine;

  pname = "sierrachart";
  version = "2347";

  src = fetchurl {
    url = "https://www.sierrachart.com/downloads/ZipFiles/SierraChart${version}.zip";
    sha256 = "1nzhnhl55p9qhrz8baig28k90rhnb2dgn27nchm2cf9388lk7cb2";
  };

  dontUnpack = true;
  wineArch = "win64";
  enableInstallNotification = false;
  nativeBuildInputs = [ unzip copyDesktopItems copyDesktopIcons ];

  fileMap = { "$HOME/.local/share/sierrachart/Data" = "drive_c/SierraChart/Data"; 
              "$HOME/.local/share/sierrachart/Graphics/Buttons" = "drive_c/SierraChart/Graphics/Buttons";
              "$HOME/.local/share/sierrachart/Sierra4.config" = "drive_c/SierraChart/Sierra4.config"; 
              "$HOME/.local/share/sierrachart/Accounts4.config" = "drive_c/SierraChart/Accounts4.config"; 
              "$HOME/.local/share/sierrachart/KeyboardShortcuts4.config" = "drive_c/SierraChart/KeyboardShortcuts4.config"; 
              "$HOME/.local/share/sierrachart/TradeActivityLogs" = "drive_c/SierraChart/TradeActivityLogs"; 
              "$HOME/.local/share/sierrachart/TradePositions.data" = "drive_c/SierraChart/TradePositions.data"; 
              "$HOME/.local/share/sierrachart/AccountBalance.data" = "drive_c/SierraChart/AccountBalance.data"; 
              "$HOME/.local/share/sierrachart/TradeOrdersList.data" = "drive_c/SierraChart/TradeOrdersList.data"; 
              "$HOME/.local/share/sierrachart/SymbolSettings" = "drive_c/SierraChart/SymbolSettings"; 
              "$HOME/.local/share/sierrachart/DefaultStudySettings" = "drive_c/SierraChart/DefaultStudySettings"; 
              "$HOME/.local/share/sierrachart/AlertSounds" = "drive_c/SierraChart/AlertSounds"; 
  };

  winAppInstall = ''
    d="$WINEPREFIX/drive_c/SierraChart"
    mkdir -p "$d"
    unzip ${src} -d "$d"
    rm -fR "$d/NPP"
  '';

  winAppRun = ''
   wine "$WINEPREFIX/drive_c/SierraChart/SierraChart.exe" "$ARGS"
  '';

  installPhase = ''
    runHook preInstall

    ln -s $out/bin/.launcher $out/bin/sierrachart

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = pname;
      exec = pname;
      icon = pname;
      desktopName = "Sierra Chart";
      genericName = "Trading and charting software";
      categories = "Network;Finance;";
    })
  ];

  desktopIcon = makeDesktopIcon {
    name = "sierrachart";

    src = fetchurl {
      url = "https://www.sierrachart.com/favicon/favicon-192x192.png";
      sha256 = "06wdklj01i0h6c6b09288k3qzvpq1zvjk7fsjc26an20yp2lf21f";
    };
  };

  meta = with lib; {
    description = "A professional desktop Trading and Charting platform for the financial markets, supporting connectivity to various exchanges and backend trading platform services.";
    homepage = "https://www.sierrachart.com";
    license = licenses.unfree;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "x86_64-linux" ];
  };
}

