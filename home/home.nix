{ pkgs, inputs, ... }: {
  home.stateVersion = "23.05";
  nix = {
    settings.experimental-features = [ "flakes" "nix-command" ];
  };
  home.packages = with pkgs; [
    #texlive.combined.scheme-full
    #(agda.withPackages [ agdaPackages.standard-library agdaPackages.agda-categories ])
    zip
    unzip
    neofetch
    ack
    dua       # Disk usage analyzer
    gource    # SVC visualization
    hyperfine # Command-line benchmarking tool
    pv        # Monitor the progress of data through a pipe
    nixfmt
    nix-tree
    gh
  ];
  programs.direnv  = { enable = true; nix-direnv.enable = true; };
  #programs.atuin   = { enable = true; enableFishIntegration = true; };
  programs.zoxide  = { enable = true; enableFishIntegration = true; };
  programs.ssh     = { enable = true; package = pkgs.openssh; addKeysToAgent = "yes"; };
  programs.ripgrep = { enable = true; };
  programs.btop    = { enable = true; };
  programs.bat     = { enable = true; };
  programs.eza     = { enable = true; };
  programs.git = {
    enable = true;
    diff-so-fancy.enable = true;
    userName  = "iwilare";
    userEmail = "iwilare@gmail.com";

    extraConfig.color.ui = true;
    extraConfig.core.askPass = "";
    extraConfig.core.fileMode = true;
    extraConfig.core.editor = "code --wait";
    extraConfig.credential.helper = "store";
    extraConfig.github.user = "iwilare";
    extraConfig.init.defaultBranch = "main";
    extraConfig.push.autoSetupRemote = true;
    extraConfig.pull.rebase = true;
    #extraConfig.merge.autoStash = true;
    extraConfig.url."https://github.com/".insteadOf = [ "gh:" "github:" ];
    extraConfig.commit.gpgsign = true;
    extraConfig.gpg.format = "ssh";
    extraConfig.user.signingKey = "key::ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC070EeFAV0Uj5OSrIeSzPn7oj/Vr3Rj5eXAA13c/iug iwilare@gmail.com";
  };
  programs.fish = {
    enable = true;
    functions = {
      fish_prompt.body = ''
        set -l last_status $status
        set -l prompt_nix ""
        set -l prompt_stat ""
        set -l prompt_folder (set_color $fish_color_cwd)(prompt_pwd)(set_color normal)
        if test -n "$IN_NIX_SHELL"; set prompt_nix "(nix) "; end
        if test $last_status -ne 0; set prompt_stat (set_color red)" [$last_status]"(set_color normal); end
        echo -n "λ "$prompt_nix$prompt_folder$prompt_stat"> "
      '';
      nix-run = "nix run nixpkgs#$argv[1] -- $argv[2..]";
      proj = "z $argv[1] && n";
    };
    shellAbbrs = {
      q   = { expansion = "git commit -am '%'"; setCursor = true; };
      a   = { expansion = "git commit -a --amend -m '%'"; setCursor = true; };
      ns  = { expansion = "nix shell nixpkgs#%"; setCursor = true; };
      gg  = { expansion = "git clone git@github.com:%"; setCursor = true; };
      o   = { expansion = "set -l REPO=(basename $PWD)% && gh repo create --private iwilare/$REPO && git remote add origin git@github.com:iwilare/$REPO"; setCursor = true; };
      yt  = { expansion = "nix-run youtube-dl -x --audio-format mp3 --audio-quality 0 -o 'C:\\Dropbox\\Music\\%%(title)s.%%(ext)s' '|'"; setCursor = "|"; };
    };
    shellAliases = {
      w  = "ack -il";
      e  = "explorer.exe .";
      l  = "eza --git --icons --time-style=long-iso --long --no-user --no-permissions -s=type";
      la = "eza --git --icons --time-style=long-iso --long -s=type --all";
      t  = "eza --icons --tree -s=type --all";
      ta = "eza --icons --tree -s=type";

      d  = "git diff";
      ds = "git diff --stat";
      s  = "git status --show-stash";
      p  = "git push";
      ll = "git log --pretty=format:'%C(auto) %h %ci [%an] %s%d' -n 10 --graph";
      pf = "git push --force";
      fix = "git commit -a --amend --no-edit";
      save = "git commit -am (date '+%Y-%m-%d %H:%M:%S') && git push";

      RM = "rm -rfd";
      dn = "nextd";
      dp = "prevd";
      diff = "diff-so-fancy";

      sd = "nix develop --command fish";
      c  = "nix develop --command code .";
      b  = "nix build && cd result";
      nr = "nix-run";
      nl = "nix log";

      no  = "code /etc/nixos/";
      nod = "cd /etc/nixos/";
      nos = "sudo nixos-rebuild switch";
      hm  = "code ~/.config/home-manager";
      hmd = "cd ~/.config/home-manager";
      hms = "home-manager switch -b backup --flake ~/.config/home-manager#${if !pkgs.stdenv.isDarwin then "andrea" else "andrea-macos"}";
      hmss = "save && hms";

      nv = "nix run ~/Dropbox/Repos/neovim";
    };
    shellInit = ''
      set fish_greeting

      if not test -e ~/.ssh/id_ed25519
        mkdir -p ~/.ssh/repository
        set temp_dir '~/.ssh/repository'
        echo 'Adding ssh keys...'
        ${pkgs.git}/bin/git clone https://github.com/iwilare/ssh $temp_dir
        cp -r $temp_dir/. ~/.ssh/
        chmod 600 ~/.ssh/id_ed25519
        rm -rf $temp_dir
      end
    '';
    plugins = [
      {
        name = "nix-env.fish";
        src = pkgs.fetchFromGitHub {
          owner = "lilyball";
          repo = "nix-env.fish";
          rev = "7b65bd228429e852c8fdfa07601159130a818cfa";
          sha256 = "sha256-RG/0rfhgq6aEKNZ0XwIqOaZ6K5S4+/Y5EEMnIdtfPhk=";
        };
      }
    ];
  };
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = pkgs.lib.concatStrings [
        "[](#3060B0)"
        "[λ ](fg:#E0E0E0 bg:#3060B0)"
        "$directory"
        "[](#3060B0)"
        " "
        "$git_branch"
        "$nix_shell"
        "$hostname"
        "$rust"
        "$status"
        "❯ "
      ];
      directory = {
        format = "[$path]($style)[$read_only]($read_only_style)";
        style = "fg:#E0E0E0 bg:#3060B0";
        read_only_style = "fg:#E0E0E0 bg:#3060B0";
        truncate_to_repo = true;
        truncation_symbol = "…/";
        fish_style_pwd_dir_length = 1;
        read_only = " 🔒";
      };
      git_branch = {
        format = "[](#A03050)[$symbol$branch(:$remote_branch)]($style)[](#A03050) ";
        style = "fg:#E0E0E0 bg:#A03050";
      };
      nix_shell = {
        format = "[](#00B0C0)[🞱](fg:#E0E0E0 bg:#00B0C0)[](#00B0C0) ";
        heuristic = true;
      };
      rust = {
        format = "[](#C06060)[$symbol($version)]($style)[](#C06060) ";
        style = "fg:#E0E0E0 bg:#C06060";
      };
      # hostname = {
      #   ssh_only = true;
      #   format = "$ssh_symbol$hostname ";
      # };
      # status = {

      # };
    };
  };
  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
    shellWrapperName = "y";

    settings = {
      preview = {
        max_width = 1000;
        max_height = 1000;
      };
    };

    plugins = {
      full-border = "${inputs.yazi-plugins}/full-border.yazi";
      max-preview = "${inputs.yazi-plugins}/max-preview.yazi";
      fuse-archive = "${inputs.fuse-archive-yazi}";
    };

    initLua = ''
      require("full-border"):setup()
    '';

    keymap = {
      manager.prepend_keymap = [
        {
          on = "T";
          run = "plugin --sync max-preview";
          desc = "Maximize or restore the preview pane";
        }
      ];
    };
  };
}
