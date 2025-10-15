{ lib
, stdenv
, fetchFromGitHub
, makeWrapper
, apple-sdk
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "displayplacer";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "jakehilborn";
    repo = "displayplacer";
    rev = "v${finalAttrs.version}";
    hash = "sha256-BYq8lrS8yE9ARCdAvZxiuC/2vRv6uha++WwKfM37gC0=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    apple-sdk.privateFrameworksHook
    apple-sdk
  ];

  buildPhase = ''
    make -C src displayplacer
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp src/displayplacer $out/bin/
  '';

  meta = {
    description = "Command-line utility for macOS to configure multi-display resolutions and arrangements";
    homepage = "https://github.com/jakehilborn/displayplacer";
    changelog = "https://github.com/jakehilborn/displayplacer/releases/tag/v${finalAttrs.version}";
    mainProgram = "displayplacer";
    platforms = lib.platforms.darwin;
    license = lib.licenses.mit;
  };
})
