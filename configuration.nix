# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  # networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  # time.timeZone = "Europe/Amsterdam";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp0s3.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n = { defaultLocale = "en_GB.UTF-8"; }; 
  console = { keyMap = "uk"; };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  services.xserver.windowManager.i3.enable = true;

  # Configure keymap in X11
  services.xserver.layout = "gb";
  services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.edward = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ]; # Enable ‘sudo’ for the user.
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    firefox
    tmux
    linuxPackages.virtualboxGuestAdditions
    ack
    fzf
    alacritty
    rofi
    flameshot
    scrot
    git
    (neovim.override {
      configure = {
        customRC = ''
        set nocompatible              " Don't be compatible with vi
        set grepprg=ack               " replace the default grep program with ack

        let mapleader=","             " change the leader to be a comma vs slash

        nmap <leader>a <Esc>:Ack!

        " Do not use smartindent, instead rely on filetype plugin indent on
        " set smartindent             " use smart indent if there is no indent file
        set tabstop=2               " <tab> inserts 4 spaces 
        set shiftwidth=2            " but an indent level is 2 spaces wide.
        set softtabstop=2           " <BS> over an autoindent deletes both spaces.
        set expandtab               " Use spaces, not tabs, for autoindent/tab key.
        set shiftround              " rounds indent to a multiple of shiftwidth
        set matchpairs+=<:>         " show matching <> (html mainly) as well
        set foldmethod=indent       " allow us to fold on indents
        set foldlevel=99            " don't fold by default

        nmap <leader>t :Files<CR>
        nmap <leader>b :Buffers<CR>

        '';

        packages.myVimPackage = with pkgs.vimPlugins; {
          # see examples below how to use custom packages
          start = [ vim-airline ack-vim fzf-vim ];
          opt = [ ];
        };      
      };
    })
  ];

  programs.neovim.enable = true;

  services.xserver.windowManager.i3.configFile = pkgs.writeText "i3.cfg" ''
    set $super Mod4
    set $mod Mod1

    bindsym $mod+1 workspace 1
    bindsym $mod+2 workspace 2
    bindsym $mod+3 workspace 3
    bindsym $mod+4 workspace 4
    bindsym $mod+5 workspace 5
    bindsym $mod+6 workspace 6

    bindsym $mod+Shift+1 move container to workspace 1
    bindsym $mod+Shift+2 move container to workspace 2
    bindsym $mod+Shift+3 move container to workspace 3
    bindsym $mod+Shift+4 move container to workspace 4
    bindsym $mod+Shift+5 move container to workspace 5
    bindsym $mod+Shift+6 move container to workspace 6

    bindsym $mod+Return exec ${pkgs.alacritty}/bin/alacritty
    bindsym $mod+Shift+d exec i3-dmenu-desktop --dmenu="dmenu -i -fn 'Noto Sans:size=8'"
    bindsym $mod+d exec rofi -lines 12 -padding 18 -width 60 -location 0 -show drun -sidebar-mode -columns 3 -font 'Noto Sans 8'
    bindsym Control+Shift+4 exec scrot 'Cheese_%a-%d%b%y_%H.%M.png' -e 'viewnior ~/$f'

    bar {
	    colors {
		    background #2f343f
			    statusline #2f343f
			    separator #4b5262

			    # colour of border, background, and text
			    focused_workspace       #2f343f #bf616a #d8dee8
			    active_workspace        #2f343f #2f343f #d8dee8
			    inactive_workspace      #2f343f #2f343f #d8dee8
			    urgent_workspacei       #2f343f #ebcb8b #2f343f
	    }
	    status_command i3status
    }

    bindsym $mod+h focus left
    bindsym $mod+j focus down
    bindsym $mod+k focus up
    bindsym $mod+l focus right
  '';

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
 
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

  environment.shellAliases = { 
    vim = "nvim"; 
    vi = "nvim"; 
  };

  virtualisation.docker.enable = true;
  virtualisation.docker.package = pkgs.docker-edge;

  programs.bash.shellInit = ''
    if command -v fzf-share >/dev/null; then
      source "$(fzf-share)/key-bindings.bash"
      source "$(fzf-share)/completion.bash"
    fi
  '';
}

