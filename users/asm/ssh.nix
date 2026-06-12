{
  programs.ssh = {
    enable = true;

    enableDefaultConfig = false;

    extraConfig = ''
      UseKeychain yes
    '';

    includes = [ "~/.ssh/config.private" ];

    settings = {
      "*" = {
        ForwardAgent = false;
        AddKeysToAgent = "yes";
      };

      "i-*" = {
        ProxyCommand = ''
          sh -c "aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'"
        '';
      };

      "util" = {
        User = "ec2-user";
        IdentityFile = "~/.ssh/id_ed25519";
        CheckHostIP = false;
        StrictHostKeyChecking = "no";
        UserKnownHostsFile = "/dev/null";
        proxyCommand = "~/bin/util-ssh";
      };
    };
  };
}
