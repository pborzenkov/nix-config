final: prev:

{
  ankisyncd-rs = final.callPackage ./packages/ankisyncd-rs { };

  mpdsonic = final.callPackage ./packages/mpdsonic { };

  rtorrent-exporter = final.callPackage ./packages/rtorrent-exporter { };
}
