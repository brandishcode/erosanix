{ config, pkgs, lib, ... }:

with lib;

let cfg = config.services.protonvpn;
in {
  options = {

    services.protonvpn = {
      enable = mkEnableOption "Enable ProtonVPN."; 

      upScript = mkOption {
        default = "";
        example = "systemctl start super-secret.service";
        type = types.lines;
        description = ''Shell commands to execute when the VPN is starting.'';
      };

      downScript = mkOption {
        default = "";
        example = "systemctl stop super-secret.service";
        type = types.lines;
        description = ''Shell commands to execute when the VPN is stopping.'';
      };

      autoStart = mkOption {
        type = types.bool;
        default = true;
        example = "true";
        description = "When set to true, the VPN connection is established automatically upon boot. When set to false the VPN connection is not established automatically; It can be started with `systemctl start openvpn-protonvpn-SERVERNAME.service`, where SERVERNAME is the name of the ProtonVPN server; See the `name` option.";
      };

      authentication = mkOption {
        description = "The method used to store the authentication credentials. Note that you need the OpenVPN credentials, not the ProtonMail credentials, which you can get here: `https://account.protonmail.com/u/0/vpn/open-vpn-ike-v2`. This option can be set to either a path to a file containing two lines; username and password. For example, /run/secrets/protonvpn. This method is useful if you want to store the credentials in `/root` or deploy them into `/run/secrets` with `agenix` or `nixops`. Alternatively, the value of this option could be a set containing the credentials, which would expose them in the Nix store.";
        example = ''{ username = "john"; password = "galt" }'';
        type = types.either types.path (types.submodule {
          options = {
            username = mkOption {
              type = types.str;
              default = null;
              example = "dagny";
              description = "The user name to use for ProtonVPN authentication.";
            };

            password = mkOption {
              type = types.str;
              default = null;
              example = "ilovejohn";
              description = "The password to use for ProtonVPN authentication.";
            };
          };
        });
      };

      server = mkOption {
        type = types.str;
        default = "us-free-01.protonvpn.com";
        example = "us-free-01.protonvpn.com";
        description = "The ProtonVPN server to use. You can choose a server from the lists provided here: `https://account.protonmail.com/u/0/vpn/open-vpn-ike-v2`";
      };

      protocol = mkOption {
        type = types.enum [ "udp" "tcp" ];
        default = "udp";
        example = "tcp";
        description = "The network protocol to use for the VPN connection. See `https://protonvpn.com/support/udp-tcp/`";
      };
    };
  };

  config = mkIf cfg.enable {
    services.openvpn.servers.protonvpn = {
      up = cfg.upScript;
      down = cfg.downScript;
      autoStart = cfg.autoStart;

      config = let
        authConfig = if (builtins.isString cfg.authentication) then
                       "auth-user-pass ${cfg.authentication}"
                     else
                       "auth-user-pass ${pkgs.writeText "protonvpn-credentials-${cfg.server}" ''
                       ${cfg.authentication.username}
                       ${cfg.authentication.password}
                       ''}";
      in ''
        client
        dev tun
        proto ${cfg.protocol}
        
        remote ${cfg.server} 80
        remote ${cfg.server} 443
        remote ${cfg.server} 4569
        remote ${cfg.server} 1194
        remote ${cfg.server} 5060
        
        remote-random
        resolv-retry infinite
        nobind
        cipher AES-256-CBC
        auth SHA512
        comp-lzo no
        verb 3
        
        tun-mtu 1500
        tun-mtu-extra 32
        mssfix 1450
        persist-key
        persist-tun
        
        reneg-sec 0
        
        remote-cert-tls server
        ${authConfig}
        pull
        fast-io
        
        script-security 2
        
        <ca>
        -----BEGIN CERTIFICATE-----
        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
        A1gTTlpi7A==
        -----END CERTIFICATE-----
        </ca>
        
        key-direction 1
        <tls-auth>
        # 2048 bit OpenVPN static key
        -----BEGIN OpenVPN Static key V1-----
        6acef03f62675b4b1bbd03e53b187727
        423cea742242106cb2916a8a4c829756
        3d22c7e5cef430b1103c6f66eb1fc5b3
        75a672f158e2e2e936c3faa48b035a6d
        e17beaac23b5f03b10b868d53d03521d
        8ba115059da777a60cbfd7b2c9c57472
        78a15b8f6e68a3ef7fd583ec9f398c8b
        d4735dab40cbd1e3c62a822e97489186
        c30a0b48c7c38ea32ceb056d3fa5a710
        e10ccc7a0ddb363b08c3d2777a3395e1
        0c0b6080f56309192ab5aacd4b45f55d
        a61fc77af39bd81a19218a79762c3386
        2df55785075f37d8c71dc8a42097ee43
        344739a0dd48d03025b0450cf1fb5e8c
        aeb893d9a96d1f15519bb3c4dcb40ee3
        16672ea16c012664f8a9f11255518deb
        -----END OpenVPN Static key V1-----
        </tls-auth>
      '';
    };
  };

  meta.maintainers = with maintainers; [ emmanuelrosa ];
}
