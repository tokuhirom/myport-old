url 'http://labs.cybozu.co.jp/blog/kazuho/archives/c/C-0.06.tar.gz';

sub install {
    run "./configure", '--prefix=' . prefix();
    run "make";
    run "make install";
}
