{
  description = "A flake for Tor Browser";

  inputs.nixpkgs.url = github:NixOS/nixpkgs/b67e752c29f18a0ca5534a07661366d6a2c2e649;

  outputs = { self, nixpkgs }: {
    defaultPackage.x86_64-linux =
      with import nixpkgs { system = "x86_64-linux"; };

      stdenv.mkDerivation rec {
        name = "tor-browser_sk4zuzu";
        version = "10.5.10";

        wrapper = fetchurl {
          url = "https://raw.githubusercontent.com/sk4zuzu-nix/tor-browser-flk/master/tor-browser-flk";
          sha256 = "sha256-MzUXVjpvk/+FpvKKHg46lHA6tPb2Dhk3+f5l7ju6+hs=";
          executable = true;
        };

        src = fetchurl {
          url = "https://www.torproject.org/dist/torbrowser/${version}/tor-browser-linux64-${version}_en-US.tar.xz";
          sha256 = "sha256-gnllLeIsmEJ1UZbNhhaHunOj1GodXJTcLBJT4QSkbFc=";
        };

        buildInputs = [ gtk3-x11 dbus-glib xorg.libXt ];

        nativeBuildInputs = [ autoPatchelfHook ];

        autoPatchelfIgnoreMissingDeps = true;

        dontPatch     = true;
        dontConfigure = true;
        dontBuild     = true;

        installPhase = ''
          install -d $out/
          cp -r Browser/* $out/
          cp $wrapper $out/tor-browser-flk

          interp=$(< $NIX_CC/nix-support/dynamic-linker)

          sed -i $out/TorBrowser/Data/Tor/torrc-defaults \
              -e "s,./TorBrowser,$out/share/tor-browser-flk/TorBrowser,g"

          sed -i $out/TorBrowser/Data/Tor/torrc-defaults \
              -e "s|\(ClientTransportPlugin meek_lite,obfs2,obfs3,obfs4,scramblesuit\) exec|\1 exec $interp|"

          sed -i $out/TorBrowser/Data/Tor/torrc-defaults \
              -e "s|\(ClientTransportPlugin snowflake\) exec|\1 exec $interp|"
        '';
      };
  };
}
