{ config, pkgs, ... }:

{
  programs.zsh.enable = true;
  services.nix-daemon.enable = true;
  system.stateVersion = 4;

  system = {
    defaults = {
      NSGlobalDomain = {
        # Disable "smart" auto-correction
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;

        # Forget about iCloud
        NSDocumentSaveNewDocumentsToCloud = false;
      };

      dock = {
        autohide = true;
        orientation = "left";
      };

      finder = {
        # Show file extensions in Finder
        AppleShowAllExtensions = true;
        # And don't show icons on the desktop
        CreateDesktop = false;
        # Don't bother me with a warning about renaming a file extension
        FXEnableExtensionChangeWarning = false;
      };

      # Disable guest user
      loginwindow.GuestEnabled = false;
    };
  };
}
