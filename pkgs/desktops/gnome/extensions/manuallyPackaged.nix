{ callPackage }:
{
  appindicator = callPackage ./appindicator { };
  arcmenu = callPackage ./arcmenu { };
  caffeine = callPackage ./caffeine { };
  clipboard-indicator = callPackage ./clipboard-indicator { };
  clock-override = callPackage ./clock-override { };
  dash-to-dock = callPackage ./dash-to-dock { };
  dash-to-panel = callPackage ./dash-to-panel { };
  disable-unredirect = callPackage ./disable-unredirect { };
  draw-on-your-screen = callPackage ./draw-on-your-screen { };
  drop-down-terminal = callPackage ./drop-down-terminal { };
  dynamic-panel-transparency = callPackage ./dynamic-panel-transparency { };
  easyScreenCast = callPackage ./EasyScreenCast { };
  emoji-selector = callPackage ./emoji-selector { };
  freon = callPackage ./freon { };
  fuzzy-app-search = callPackage ./fuzzy-app-search { };
  gsconnect = callPackage ./gsconnect { };
  hot-edge = callPackage ./hot-edge { };
  icon-hider = callPackage ./icon-hider { };
  impatience = callPackage ./impatience { };
  material-shell = callPackage ./material-shell { };
  mpris-indicator-button = callPackage ./mpris-indicator-button { };
  night-theme-switcher = callPackage ./night-theme-switcher { };
  no-title-bar = callPackage ./no-title-bar { };
  noannoyance = callPackage ./noannoyance { };
  paperwm = callPackage ./paperwm { };
  pidgin-im-integration = callPackage ./pidgin-im-integration { };
  remove-dropdown-arrows = callPackage ./remove-dropdown-arrows { };
  sound-output-device-chooser = callPackage ./sound-output-device-chooser { };
  system-monitor = callPackage ./system-monitor { };
  taskwhisperer = callPackage ./taskwhisperer { };
  tilingnome = callPackage ./tilingnome { };
  timepp = callPackage ./timepp { };
  topicons-plus = callPackage ./topicons-plus { };
  unite = callPackage ./unite { };
  window-corner-preview = callPackage ./window-corner-preview { };
  window-is-ready-remover = callPackage ./window-is-ready-remover { };
  workspace-matrix = callPackage ./workspace-matrix { };
}
