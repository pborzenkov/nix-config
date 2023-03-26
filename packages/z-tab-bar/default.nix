{
  lib,
  fetchFromGitHub,
  rust-bin,
  makeRustPlatform,
}: let
  rust = rust-bin.stable.latest.minimal.override {
    targets = ["wasm32-wasi"];
  };

  rustPlatform = makeRustPlatform {
    rustc = rust;
    cargo = rust;
  };
in
  rustPlatform.buildRustPackage rec {
    pname = "z-tab-bar";
    version = "0.2.0";

    src = fetchFromGitHub {
      owner = "casonadams";
      repo = "z-tab-bar";
      rev = "v${version}";
      sha256 = "sha256-N9cq5aB4t9vv9O+uFTb0JHI0vHRZprvJM3kUwOHvZ1E=";
    };

    cargoSha256 = "sha256-oB28wtSG/JWNVzMToEuEFJRaQLBFhAgiJ4SwuDJW18c=";

    buildPhase = ''
      cargo build --release
    '';

    installPhase = ''
      mkdir -p $out/lib
      cp target/wasm32-wasi/release/*.wasm $out/lib/
    '';

    meta = with lib; {
      description = "zellij tab-bar plugin that is similar to tmux default status line";
      homepage = "https://github.com/casonadams/z-tab-bar";
      maintainers = with maintainers; [pborzenkov];
    };
  }
